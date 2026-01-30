# Changelog

## 3.0.2

- Fix model selection for language
- Add missing `onnx_asr` dependency

## 3.0.1

- Add support for `sherpa-onnx` and Nvidia's parakeet model
- Prefer parakeet model in `auto`
- Add support for GigaAM for Russian
- Add `stt_library` option to choose backend

## 2.6.0

- Upgrade to Debian bookworm
- Add support for HuggingFace transformers Whisper models

## 2.5.0

- Added configuration mapping to access local models.
- Updated documentation about `custom_model` usage.

## 2.4.0

- Add "auto" for model and beam size (0) to select values based on CPU

## 2.3.1

- Move `turbo` down the list closer to `large` to avoid confusion

## 2.3.0

- Bump `wyoming-whisper` to 2.3.0 (`faster-whisper` to 1.1.0)
- Supports model `turbo` for faster processing

## 2.2.0

- Bump `wyoming-whisper` to 2.2.0 (`faster-whisper` to 1.0.3)

## 2.1.2

- Fix excluding models files from backup

## 2.1.1

- Exclude `data/models*` files from backup

## 2.1.0

- Add distil-large-v3 `model` option

## 2.0.0

- Add more models for `model` option
- Add "custom" option for `model` that will use `custom_model` instead
- Add `custom_model` that can be a path to a model directory or HuggingFace Hub model ID
- Use faster-whisper PyPI package
- Add `initial_prompt` for helping with unusual words (see: https://github.com/openai/whisper/discussions/963)

## 1.0.2

- Convert error to warning for CPUs not supporting AVX instructions

## 1.0.1

- Handle unsupported CPU configurations

## 1.0.0

- Upgrade to `wyoming-whisper` 1.0.1
- Allow multiple languages to be used simultaneously without restart

## 0.2.1

- Exclude `*.bin` model files from backup

## 0.2.0

- Hash model files at startup to detect bad downloads
- Fix "auto" language

## 0.1.1

- Enable Wyoming protocol discovery

## 0.1.0

- Initial release
