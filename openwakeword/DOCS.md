# Home Assistant Add-on: openWakeWord

## Installation

Follow these steps to get the add-on installed on your system:

1. Navigate in your Home Assistant frontend to **Settings** -> **Add-ons** -> **Add-on store**.
2. Find the "openWakeWord" add-on and click it.
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

### Option: `threshold`

Activation threshold (0-1), where higher means fewer activations.  See trigger
level for the relationship between activations and wake word detections.

### Option: `trigger_level`

Number of activations before a detection is registered. A higher trigger level
means fewer detections.

### Option: `debug_logging`

Enable debug logging. Useful for seeing satellite connections and each wake word detection in the logs.

## Custom Wake Word Models

The add-on will automatically load custom wake word models from the `/share/openwakeword` directory. [Install the Samba add-on](https://www.home-assistant.io/common-tasks/supervised/#installing-and-using-the-samba-add-on) to copy wake word model files (`*.tflite`) to this directory.

After adding new models to `/share/openwakeword`, make sure to reload any Wyoming integrations for openWakeWord. Once reloaded, the new wake words will be available to select in the Voice Assistants settings page.

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
