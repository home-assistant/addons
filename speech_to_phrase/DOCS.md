# Home Assistant App: Speech to phrase

## Installation

Follow these steps to get the app (formerly known as add-on) installed on your system:

1. Navigate in your Home Assistant frontend to **Settings** > **Apps** > **App store**.
2. Find the "Speech to phrase" app and click it.
3. Click on the "INSTALL" button.

## How to use

After this app is installed and running, it should automatically train itself based on your [exposed][] entities, areas, floors, and [sentence triggers][sentence trigger].
The app will automatically re-train if necessary.

The app will be automatically discovered by the Wyoming integration in Home Assistant. To finish the setup, click the following my button:

[![Open your Home Assistant instance and start setting up a new integration.](https://my.home-assistant.io/badges/config_flow_start.svg)](https://my.home-assistant.io/redirect/config_flow_start/?domain=wyoming)

Alternatively, you can install the Wyoming integration manually, see the
[Wyoming integration documentation](https://www.home-assistant.io/integrations/wyoming/)
for more information.

### Voice commands

See [available voice commands](https://github.com/OHF-Voice/speech-to-phrase/blob/main/SENTENCES.md)

### Custom sentences

You can add [custom sentences][] to `/share/speech-to-phrase/custom_sentences/<language>/sentences.yaml` where `<language>` is:

* `ca` - Catalan
* `cs` - Czech
* `de` - German
* `el` - Greek
* `en` - English
* `es` - Spanish
* `eu` - Basque
* `fa` - Persian/Farsi
* `fi` - Finnish
* `fr` - French
* `hi` - Hindi
* `it` - Italian
* `mn` - Mongolian
* `nl` - Dutch
* `pl` - Polish
* `pt_PT` - Portuguese
* `ro` - Romanian
* `ru` - Russian
* `sl` - Slovenian
* `sw` - Swahili
* `tr` - Turkish

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

[sentence trigger]: https://www.home-assistant.io/docs/automation/trigger/#sentence-trigger
[exposed]: https://www.home-assistant.io/voice_control/voice_remote_expose_devices/
[custom sentences]: https://github.com/OHF-voice/speech-to-phrase?tab=readme-ov-file#custom-sentences
