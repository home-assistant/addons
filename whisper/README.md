# Home Assistant App: Whisper

![Supports aarch64 Architecture][aarch64-shield] ![Supports amd64 Architecture][amd64-shield]

Home Assistant app (formerly known as add-on) that uses multiple speech-to-text
backends, selected with the `stt_library` option:

- `faster-whisper` — [Whisper][faster-whisper] models, and the fallback for
  every other backend
- `sherpa` — [Parakeet][parakeet] and Kroko streaming models via
  [sherpa-onnx][sherpa-onnx]
- `onnx-asr` — [GigaAM][gigaam] and other ONNX models via [onnx-asr][onnx-asr]
- `funasr` — [SenseVoice][sensevoice] via [FunASR][funasr]
- `transformers` — Whisper models via [HuggingFace transformers][transformers]
- `qwen3-asr` — [Qwen3-ASR][qwen3-asr], which biases hardest toward the names of
  your Home Assistant entities

The default `auto` picks a backend and model from your language and hardware:
sherpa for English, FunASR for Chinese, Cantonese, Japanese and Korean, onnx-asr
for Russian, and faster-whisper for everything else. `transformers` and
`qwen3-asr` are never picked automatically and have to be selected.

The `transformers` and `funasr` backends are downloaded the first time your
configuration selects one, rather than shipping in the app.

See [DOCS.md](DOCS.md) for all of the options.

Part of the [Year of Voice](https://www.home-assistant.io/blog/2022/12/20/year-of-voice/).

[aarch64-shield]: https://img.shields.io/badge/aarch64-yes-green.svg
[amd64-shield]: https://img.shields.io/badge/amd64-yes-green.svg
[faster-whisper]: https://github.com/SYSTRAN/faster-whisper
[funasr]: https://github.com/modelscope/FunASR
[gigaam]: https://github.com/salute-developers/GigaAM
[onnx-asr]: https://github.com/istupakov/onnx-asr
[parakeet]: https://huggingface.co/nvidia/parakeet-tdt-0.6b-v3
[qwen3-asr]: https://huggingface.co/Qwen/Qwen3-ASR-0.6B
[sensevoice]: https://huggingface.co/FunAudioLLM/SenseVoiceSmall
[sherpa-onnx]: https://github.com/k2-fsa/sherpa-onnx
[transformers]: https://huggingface.co/docs/transformers
