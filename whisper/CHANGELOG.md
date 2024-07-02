# Changelog

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
