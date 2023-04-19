#!/usr/bin/env python3
import argparse
import asyncio
import json
import logging
import math
import os
import tempfile
import wave
from functools import partial
from pathlib import Path

from wyoming.audio import AudioChunk, AudioStart, AudioStop
from wyoming.event import Event
from wyoming.info import Attribution, Describe, Info, TtsProgram, TtsVoice
from wyoming.server import AsyncEventHandler, AsyncServer
from wyoming.tts import Synthesize

_FILE = Path(__file__)
_DIR = _FILE.parent
_LOGGER = logging.getLogger(_FILE.stem)


class PiperEventHandler(AsyncEventHandler):
    def __init__(
        self,
        wyoming_info: Info,
        cli_args: argparse.Namespace,
        piper_proc: asyncio.subprocess.Process,
        piper_proc_lock: asyncio.Lock,
        *args,
        **kwargs,
    ) -> None:
        super().__init__(*args, **kwargs)

        self.cli_args = cli_args
        self.wyoming_info_event = wyoming_info.event()
        self.piper_proc = piper_proc
        self.piper_proc_lock = piper_proc_lock

    async def handle_event(self, event: Event) -> bool:
        if Describe.is_type(event.type):
            await self.write_event(self.wyoming_info_event)
            _LOGGER.debug("Sent info")
            return True

        if not Synthesize.is_type(event.type):
            _LOGGER.warning("Unexpected event: %s", event)
            return True

        synthesize = Synthesize.from_event(event)
        raw_text = synthesize.text
        text = raw_text.strip()
        if self.cli_args.auto_punctuation and text:
            # Add automatic punctuation (important for some voices)
            has_punctuation = False
            for punc_char in self.cli_args.auto_punctuation:
                if text[-1] == punc_char:
                    has_punctuation = True
                    break

            if not has_punctuation:
                text = text + self.cli_args.auto_punctuation[0]

        async with self.piper_proc_lock:
            _LOGGER.debug("synthesize: raw_text=%s, text='%s'", raw_text, text)

            # Text in, file path out
            self.piper_proc.stdin.write((text + "\n").encode())
            await self.piper_proc.stdin.drain()

            output_path = (await self.piper_proc.stdout.readline()).decode().strip()
            _LOGGER.debug(output_path)

            wav_file: wave.Wave_read = wave.open(output_path, "rb")
            with wav_file:
                rate = wav_file.getframerate()
                width = wav_file.getsampwidth()
                channels = wav_file.getnchannels()

                await self.write_event(
                    AudioStart(
                        rate=rate,
                        width=width,
                        channels=channels,
                    ).event(),
                )

                # Audio
                audio_bytes = wav_file.readframes(wav_file.getnframes())
                bytes_per_sample = width * channels
                bytes_per_chunk = bytes_per_sample * self.cli_args.samples_per_chunk
                num_chunks = int(math.ceil(len(audio_bytes) / bytes_per_chunk))

                # Split into chunks
                for i in range(num_chunks):
                    offset = i * bytes_per_chunk
                    chunk = audio_bytes[offset : offset + bytes_per_chunk]
                    await self.write_event(
                        AudioChunk(
                            audio=chunk,
                            rate=rate,
                            width=width,
                            channels=channels,
                        ).event(),
                    )

            await self.write_event(AudioStop().event())
            _LOGGER.debug("Completed request")

            os.unlink(output_path)

        return True


# -----------------------------------------------------------------------------


async def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("model", help="Path to model file (.onnx)")
    parser.add_argument("--uri", required=True, help="unix:// or tcp://")
    parser.add_argument(
        "--auto-punctuation", default=".?!", help="Automatically add punctuation"
    )
    parser.add_argument(
        "--speaker", type=int, help="Speaker number to use (multi-speaker models only)"
    )
    parser.add_argument("--samples-per-chunk", type=int, default=1024)
    parser.add_argument("--debug", action="store_true", help="Log DEBUG messages")
    args = parser.parse_args()

    logging.basicConfig(level=logging.DEBUG if args.debug else logging.INFO)

    # Load voice info
    voice_config_path = f"{args.model}.json"
    with open(voice_config_path, "r", encoding="utf-8") as voice_config_file:
        voice_config = json.load(voice_config_file)

    num_speakers = voice_config["num_speakers"]

    model_language = voice_config["espeak"]["voice"]
    model_path = Path(args.model)
    _LOGGER.debug("Model: %s", model_path)

    wyoming_info = Info(
        tts=[
            TtsProgram(
                name="piper",
                attribution=Attribution(
                    name="rhasspy", url="https://github.com/rhasspy/piper"
                ),
                installed=True,
                voices=[
                    TtsVoice(
                        name=model_path.stem,
                        attribution=Attribution(
                            name="rhasspy", url="https://github.com/rhasspy/piper"
                        ),
                        installed=True,
                        languages=[model_language],
                    )
                ],
            )
        ],
    )

    server = AsyncServer.from_uri(args.uri)

    with tempfile.TemporaryDirectory() as temp_dir:
        speakers_args = []
        if (num_speakers > 1) and args.speaker:
            speakers_args.extend(["--speaker", str(args.speaker)])
            _LOGGER.debug("Speaker: %s", args.speaker)

        proc = await asyncio.create_subprocess_exec(
            str(_DIR / "piper"),
            "--model",
            str(args.model),
            "--output_dir",
            temp_dir,
            *speakers_args,
            stdin=asyncio.subprocess.PIPE,
            stdout=asyncio.subprocess.PIPE,
            stderr=asyncio.subprocess.DEVNULL,
        )

        _LOGGER.info("Ready")
        proc_lock = asyncio.Lock()
        await server.run(
            partial(
                PiperEventHandler,
                wyoming_info,
                args,
                proc,
                proc_lock,
            )
        )


# -----------------------------------------------------------------------------

if __name__ == "__main__":
    asyncio.run(main())
