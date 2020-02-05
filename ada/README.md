# Home Assistant Add-on: Ada

Voice assistant powered by Home Assistant.

![Supports aarch64 Architecture][aarch64-shield] ![Supports amd64 Architecture][amd64-shield] ![Supports armhf Architecture][armhf-shield] ![Supports armv7 Architecture][armv7-shield] ![Supports i386 Architecture][i386-shield]

## About

## Installation

Follow these steps to get the add-on installed on your system:

1. Navigate in your Home Assistant frontend to **Supervisor** -> **Add-on Store**.
2. Find the "Hey Ada!" add-on and click it.
3. Click on the "INSTALL" button.

## How to use

The basic thing to get the add-on running would be:

1. Select input and output audio device to use in the "Audio" configuration
   section of the add-on configuration.
2. Start the add-on.

## Configuration

Example add-on configuration:

```yaml
stt: cloud
tts: cloud
```

### Option: `stt` (required)

The Home Assistant STT (Speech-to-Text) integration to use when converting
detected audio to text for Almond to process.

Please note, this STT integration has to be configured and active in
Home Assistant before using it with this add-on!

### Option: `tts` (required)

The Home Assistant TTS (Text-to-Speech) integration to use when converting
the response from Almond back to audio.

Please note, this TTS integration has to be configured and active in
Home Assistant before using it with this add-on!

## Support

Got questions?

You have several options to get them answered:

- The [Home Assistant Discord Chat Server][discord].
- The Home Assistant [Community Forum][forum].
- Join the [Reddit subreddit][reddit] in [/r/homeassistant][reddit]

In case you've found an bug, please [open an issue on our GitHub][issue].

[aarch64-shield]: https://img.shields.io/badge/aarch64-no-red.svg
[amd64-shield]: https://img.shields.io/badge/amd64-yes-green.svg
[armhf-shield]: https://img.shields.io/badge/armhf-yes-green.svg
[armv7-shield]: https://img.shields.io/badge/armv7-yes-green.svg
[discord]: https://discord.gg/c5DvZ4e
[forum]: https://community.home-assistant.io
[i386-shield]: https://img.shields.io/badge/i386-no-red.svg
[issue]: https://github.com/home-assistant/hassio-addons/issues
[reddit]: https://reddit.com/r/homeassistant
[repository]: https://github.com/hassio-addons/repository
