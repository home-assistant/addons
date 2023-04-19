# Wyoming Piper

Home Assistant add-on that uses [piper](https://github.com/rhasspy/piper/) for text to speech.
Intended for use with the [wyoming](https://www.home-assistant.io/integrations/wyoming/) integration.


## Voices

[Listen to voice samples](https://rhasspy.github.io/piper-samples/)

Voices are named according to the following scheme: `<language>-<name>-<quality>`
The `<name>` portion comes from the dataset used to train the voice or the speaker's name if it was provided.

A voice's quality comes in 4 different levels:

* `x-low` - 16Khz, smallest/fastest
* `low` - 16Khz, fast
* `medium` - 22.05Khz, slower but better sounding
* `high` - 22.05Khz, slowest but best sounding

On a Raspberry Pi 4, up to the `medium` models will run with usable speed. If audio quality is not a priority, prefer the `low` or `x-low` voices as they will be noticeably faster than `medium`.
