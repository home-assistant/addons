# Home Assistant Add-on: Whisper

## Installation

Follow these steps to get the add-on installed on your system:

1. Navigate in your Home Assistant frontend to **Settings** -> **Add-ons** -> **Add-on store**.
2. Find the "Whisper" add-on and click it.
3. Click on the "INSTALL" button.

## How to use

After this add-on is installed and running, it will be automatically discovered
by the Wyoming integration in Home Assistant. To finish the setup,
click the following my button:

[![Open your Home Assistant instance and start setting up a new integration.](https://my.home-assistant.io/badges/config_flow_start.svg)](https://my.home-assistant.io/redirect/config_flow_start/?domain=wyoming)

Alternatively, you can install the Wyoming integration manually, see the
[Wyoming integration documentation](https://www.home-assistant.io/integrations/wyoming/)
for more information.

## Configuration

### Option: `language`

Default language for the add-on. In Home Assist 2023.8+, multiple languages can be used simultaneously by different [Assist pipelines](https://www.home-assistant.io/voice_control/voice_remote_local_assistant/).

If you select "auto", the model will run **much** slower but will auto-detect the spoken language.

[Performance of supported languages](https://github.com/openai/whisper#available-models-and-languages)

[List of two-letter language codes](https://en.wikipedia.org/wiki/List_of_ISO_639-1_codes)

### Option: `model`

Whisper model that will be used for transcription. Choose `custom` to use the model name in `custom_model`, which may be a HuggingFace model ID like "Systran/faster-distil-whisper-small.en".

The default model is `tiny-int8`, a compressed version of the smallest Whisper model which is able to run on a Raspberry Pi 4.
Compressed models (`int8`) are slightly less accurate than their counterparts, but smaller and faster. [Distilled](https://github.com/huggingface/distil-whisper) models are not compressed, but are faster and smaller than their non-distilled counterparts.

Available models:

- `tiny-int8` (compressed)
- `tiny`
- `tiny.en` (English only)
- `base-int8` (compressed)
- `base`
- `base.en` (English only)
- `small-int8` (compressed)
- `distil-small.en` (distilled, English only)
- `small`
- `small.en` (English only)
- `medium-int8` (compressed)
- `distil-medium.en` (distilled, English only)
- `medium`
- `medium.en` (English only)
- `large`
- `large-v1`
- `distil-large-v2` (distilled, English only)
- `large-v2`
- `distil-large-v3` (distilled, English only)
- `large-v3`
- `turbo` (faster than `large-v3`)

### Option: `custom_model`

Path to a converted model directory, or a CTranslate2-converted Whisper model ID from the HuggingFace Hub like "Systran/faster-distil-whisper-small.en". 

### Option: `beam_size`

Number of candidates to consider simultaneously during transcription (see [beam search](https://en.wikipedia.org/wiki/Beam_search)).

Increasing the beam size will increase accuracy at the cost of performance.

### Option: `initial_prompt`

Description of audio that can help Whisper transcribe unusual words better.
See [this discussion](https://github.com/openai/whisper/discussions/963) for an example.

## Backups

Whisper model files can be quite large, so they are automatically excluded from backups. The models will be re-downloaded when the backup is restored.

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
