# Home Assistant App: Silicon Labs Flasher App

## Installation

Follow these steps to get the app installed on your system:

1. Navigate in your Home Assistant frontend to **Settings** > **Apps** > **App Store**.
2. Find the "Silicon Labs Flasher" app and click it.
3. Click on the "INSTALL" button.

## How to use

The app needs a Silicon Labs based wireless module accessible through a
serial port (like the module on Home Assistant Yellow, Home Assistant
SkyConnect/ZBT-1 or other USB based wireless adapters).

1. Select the correct `device` in the app configuration tab and press `Save`.
2. Start the app.

## Configuration

App configuration:

| Configuration       | Description                                            |
|---------------------|--------------------------------------------------------|
| device (mandatory)  | Serial service where the Silicon Labs radio is attached |
| bootloader_baudrate | Serial port baudrate for gecko bootloader (depends on firmware)   |
| ezsp_baudrate       | Serial port baudrate for ezsp (depends on firmware)   |
| flow_control        | If hardware flow control should be enabled (depends on firmware) |
| firmware_url        | Custom URL to flash firmware from                      |

## Support

Got questions?

You have several options to get them answered:

- The [Home Assistant Discord Chat Server][discord].
- The Home Assistant [Community Forum][forum].
- Join the [Reddit subreddit][reddit] in [/r/homeassistant][reddit]

In case you've found a bug, please [open an issue on our GitHub][issue].

[discord]: https://discord.gg/c5DvZ4e
[forum]: https://community.home-assistant.io
[reddit]: https://reddit.com/r/homeassistant
[issue]: https://github.com/home-assistant/addons/issues
