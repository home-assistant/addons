# Home Assistant Add-on: Piper

## Installation

Follow these steps to get the add-on installed on your system:

1. Navigate in your Home Assistant frontend to **Settings** -> **Add-ons** -> **Add-on store**.
2. Find the "Whisper" add-on and click it.
3. Click on the "INSTALL" button.

## How to use

Install the [wyoming](https://www.home-assistant.io/integrations/wyoming/) integration in Home Assistant and point it to port 10200 of your Home Assistant server.

## Configuration

### Option: `voice`

[Listen to voice samples](https://rhasspy.github.io/piper-samples/)

Name of the Piper voice to use, such as `en-us-ryan-low`.

Voices are named according to the following scheme: `<language>-<name>-<quality>`
The `<name>` portion comes from the dataset used to train the voice or the speaker's name if it was provided.

A voice's quality comes in 4 different levels:

* `x-low` - 16Khz, smallest/fastest
* `low` - 16Khz, fast
* `medium` - 22.05Khz, slower but better sounding
* `high` - 22.05Khz, slowest but best sounding

On a Raspberry Pi 4, up to the `medium` models will run with usable speed. If audio quality is not a priority, prefer the `low` or `x-low` voices as they will be noticeably faster than `medium`.

### Option: `speaker`

Speaker number to use if the voice supports multiple speakers, such as [`en-us-libritts-high`](https://rhasspy.github.io/piper-samples/#en-us-libritts-high).

By default, the first speaker (speaker 0) will be used.

### Option: `length_scale`

Speeds up or slows down the voice. A value of 1.0 means to use the voice's default speaking rate, with < 1.0 being faster and > 1.0 being slower.

### Option: `noise_scale`

Controls the variability of audio by adding noise during audio generation. The effect highly depends on the voice itself, but in general a value of 0 removes variability and values above 1 will start to degrade audio.

### Option: `noise_w`

Controls the variability of speaking cadence (phoneme widths). The effect highly depends on the voice itself, but in general a value of 0 removes variability and values above 1 produce extreme stutters and pauses.

## Support

Got questions?

You have several options to get them answered:

- The [Home Assistant Discord Chat Server][discord].
- The Home Assistant [Community Forum][forum].
- Join the [Reddit subreddit][reddit] in [/r/homeassistant][reddit]

In case you've found an bug, please [open an issue on our GitHub][issue].

[discord]: https://discord.gg/c5DvZ4e
[forum]: https://community.home-assistant.io
[issue]: https://github.com/home-assistant/addons/issues
[reddit]: https://reddit.com/r/homeassistant
[repository]: https://github.com/hassio-addons/repository
