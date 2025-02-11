# Home Assistant Add-on: Speech to phrase

## Installation

Follow these steps to get the add-on installed on your system:

1. Navigate in your Home Assistant frontend to **Settings** -> **Add-ons** -> **Add-on store**.
2. Find the "Speech to phrase" add-on and click it.
3. Click on the "INSTALL" button.

## How to use

After this add-on is installed and running, it should automatically train itself based on your [exposed][] entities, areas, floors, and [sentence triggers][sentence trigger].
The add-on will automatically re-train if necessary.

The add-on will be automatically discovered by the Wyoming integration in Home Assistant. To finish the setup, click the following my button:

[![Open your Home Assistant instance and start setting up a new integration.](https://my.home-assistant.io/badges/config_flow_start.svg)](https://my.home-assistant.io/redirect/config_flow_start/?domain=wyoming)

Alternatively, you can install the Wyoming integration manually, see the
[Wyoming integration documentation](https://www.home-assistant.io/integrations/wyoming/)
for more information.

### Voice commands

- [English](https://github.com/OHF-Voice/speech-to-phrase/blob/main/docs/english.md)
- [Français (French)](https://github.com/OHF-Voice/speech-to-phrase/blob/main/docs/french.md)
- [Deutsch (German)](https://github.com/OHF-Voice/speech-to-phrase/blob/main/docs/german.md)
- [Nederlands (Dutch)](https://github.com/OHF-Voice/speech-to-phrase/blob/main/docs/dutch.md)
- [Spanish (Español)](https://github.com/OHF-Voice/speech-to-phrase/blob/main/docs/spanish.md)
- [Italian (Italiano)](https://github.com/OHF-Voice/speech-to-phrase/blob/main/docs/italian.md)

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
