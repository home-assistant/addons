#!/usr/bin/env python3
import argparse
import asyncio
import io
import logging
import wave
from functools import partial
from pathlib import Path
from typing import Optional

from faster_whisper import WhisperModel

from wyoming.asr import Transcript
from wyoming.audio import AudioChunk, AudioStop
from wyoming.event import Event
from wyoming.info import AsrModel, AsrProgram, Attribution, Describe, Info
from wyoming.server import AsyncEventHandler, AsyncServer

_FILE = Path(__file__)
_DIR = _FILE.parent
_LOGGER = logging.getLogger(_FILE.stem)

_WHISPER_LANGUAGES = [
    "af",
    "am",
    "ar",
    "as",
    "az",
    "ba",
    "be",
    "bg",
    "bn",
    "bo",
    "br",
    "bs",
    "ca",
    "cs",
    "cy",
    "da",
    "de",
    "el",
    "en",
    "es",
    "et",
    "eu",
    "fa",
    "fi",
    "fo",
    "fr",
    "gl",
    "gu",
    "ha",
    "haw",
    "he",
    "hi",
    "hr",
    "ht",
    "hu",
    "hy",
    "id",
    "is",
    "it",
    "ja",
    "jw",
    "ka",
    "kk",
    "km",
    "kn",
    "ko",
    "la",
    "lb",
    "ln",
    "lo",
    "lt",
    "lv",
    "mg",
    "mi",
    "mk",
    "ml",
    "mn",
    "mr",
    "ms",
    "mt",
    "my",
    "ne",
    "nl",
    "nn",
    "no",
    "oc",
    "pa",
    "pl",
    "ps",
    "pt",
    "ro",
    "ru",
    "sa",
    "sd",
    "si",
    "sk",
    "sl",
    "sn",
    "so",
    "sq",
    "sr",
    "su",
    "sv",
    "sw",
    "ta",
    "te",
    "tg",
    "th",
    "tk",
    "tl",
    "tr",
    "tt",
    "uk",
    "ur",
    "uz",
    "vi",
    "yi",
    "yo",
    "zh",
]


class FasterWhisperEventHandler(AsyncEventHandler):
    def __init__(
        self,
        wyoming_info: Info,
        cli_args: argparse.Namespace,
        model: WhisperModel,
        model_lock: asyncio.Lock,
        *args,
        **kwargs,
    ) -> None:
        super().__init__(*args, **kwargs)

        self.cli_args = cli_args
        self.wyoming_info_event = wyoming_info.event()
        self.model = model
        self.model_lock = model_lock

        self._wav_io: Optional[io.BytesIO] = None
        self._wav_file: Optional[wave.Wave_write] = None

    async def handle_event(self, event: Event) -> bool:
        if Describe.is_type(event.type):
            await self.write_event(self.wyoming_info_event)
            _LOGGER.debug("Sent info")
            return True

        if AudioChunk.is_type(event.type):
            chunk = AudioChunk.from_event(event)

            if self._wav_file is None:
                _LOGGER.debug("Receiving audio")
                self._wav_io = io.BytesIO()
                self._wav_file = wave.open(self._wav_io, "wb")
                self._wav_file.setframerate(chunk.rate)
                self._wav_file.setsampwidth(chunk.width)
                self._wav_file.setnchannels(chunk.channels)

            self._wav_file.writeframes(chunk.audio)
            return True

        if (
            AudioStop.is_type(event.type)
            and (self._wav_io is not None)
            and (self._wav_file is not None)
        ):
            _LOGGER.debug("Audio stopped")
            self._wav_file.close()
            self._wav_io.seek(0)
            async with self.model_lock:
                segments, _info = self.model.transcribe(
                    self._wav_io,
                    beam_size=self.cli_args.beam_size,
                    language=self.cli_args.language,
                )

            text = " ".join(segment.text for segment in segments)
            _LOGGER.info(text)

            await self.write_event(Transcript(text=text).event())
            _LOGGER.debug("Completed request")

            self._wav_io = None
            self._wav_file = None

            return False

        return True


async def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("model", help="Path to faster-whisper model directory")
    parser.add_argument("--uri", required=True, help="unix:// or tcp://")
    parser.add_argument(
        "--device",
        default="cpu",
        help="Device to use for inference (default: cpu)",
    )
    parser.add_argument(
        "--language",
        help="Language to set for transcription",
    )
    parser.add_argument(
        "--compute-type",
        default="default",
        help="Compute type (float16, int8, etc.)",
    )
    parser.add_argument(
        "--beam-size",
        type=int,
        default=1,
    )
    parser.add_argument("--debug", action="store_true", help="Log DEBUG messages")
    args = parser.parse_args()

    logging.basicConfig(level=logging.DEBUG if args.debug else logging.INFO)

    model_path = Path(args.model)
    _LOGGER.debug("Model: %s", model_path)

    if args.language:
        _LOGGER.debug("Language: %s", args.language)
        languages = [args.language]
    else:
        languages = _WHISPER_LANGUAGES

    wyoming_info = Info(
        asr=[
            AsrProgram(
                name="faster-whisper",
                attribution=Attribution(
                    name="Guillaume Klein",
                    url="https://github.com/guillaumekln/faster-whisper/",
                ),
                installed=True,
                models=[
                    AsrModel(
                        name=model_path.stem,
                        attribution=Attribution(
                            name="rhasspy",
                            url="https://github.com/rhasspy/models/",
                        ),
                        installed=True,
                        languages=languages,
                    )
                ],
            )
        ],
    )

    # Load converted faster-whisper model
    model = WhisperModel(
        args.model,
        device=args.device,
        compute_type=args.compute_type,
    )

    server = AsyncServer.from_uri(args.uri)
    _LOGGER.info("Ready")
    model_lock = asyncio.Lock()
    await server.run(
        partial(
            FasterWhisperEventHandler,
            wyoming_info,
            args,
            model,
            model_lock,
        )
    )


# -----------------------------------------------------------------------------

if __name__ == "__main__":
    asyncio.run(main())
