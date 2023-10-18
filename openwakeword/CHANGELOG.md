# Changelog

## 1.8.0

- Include fix for potential deadlock
- Only process wake words that a client requests
- armv7 support

## 1.7.1

- Always use wake word file name as key (avoid duplicate model loading)

## 1.7.0

- Make wake word loading completely dynamic (new models are automatically discovered)
- Rebuild Wyoming info message on each request
- Deprecate --model

## 1.6.0

- Automatically search /share/openwakeword for custom models (`*.tflite`)
- Change share permissions to read only

## 1.5.1

- Include language in wake word descriptions

## 1.5.0

- Remove webrtc (done in core now)
- Remove audio options related to webrtc
- Remove wake word option (dynamic loading)
- Dynamically load wake word models

## 1.4.0

- Add noise suppression/auto gain with webrtc

## 1.1.0

- Initial release
