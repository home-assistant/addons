# Hass.io Core Add-on: HomeMatic

HomeMatic central based on OCCU.

![Supports aarch64 Architecture][aarch64-shield] ![Supports amd64 Architecture][amd64-shield] ![Supports armhf Architecture][armhf-shield] ![Supports armv7 Architecture][armv7-shield] ![Supports i386 Architecture][i386-shield]

## About

This add-on allows you to control your HomeMatic devices so they can be
integrated into Home Assistant. It is based on the
[HomeMatic Open Central Control Unit (OCCU) SDK][occu].

Note: Requires a [HM-MOD-RPI-PCB][hm-mod-rpi-pcb] or [HmIP-RFUSB][hmip-rufsb]
to interface with your devices.

## Features

- Your Raspberry Pi is your HomeMatic control center
- WebUI (experimental)
- Firmware updates

## Installation

The installation of this add-on is straightforward and easy to do.

1. Navigate in your Home Assistant frontend to **Hass.io** -> **Add-on Store**.
2. Find the "HomeMatic CCU" add-on and click it.
3. Click on the "INSTALL" button.

## How to use

Currently, all .

1. Toggle the "Show in sidebar" option, which adds the Configurator to the main menu.
2. Start the add-on.
3. Refresh your browser, the "Configurator" is now visible in the sidebar.
4. Click on the "Configurator" menu option and start configuring!

## Configuration

Add-on configuration:

```json
{
  "dirsfirst": false,
  "enforce_basepath": false,
  "ignore_pattern": [
    "__pycache__"
  ],
  "ssh_keys": []
}
```

### Option: `dirsfirst` (required)

This option allows you to list directories before files in the file browser tree.

Set it to `true` to list files first, `false` otherwise.

### Option: `enforce_basepath` (required)

If set to `true`, access is limited to files within the `/config` directory.

### Option: `ignore_pattern` (required)

This option allows you to hide files and folders from the file browser tree.
By default, it hides the `__pycache__` folders.

### Option: `ssh_keys` (required)

A list of filenames containing SSH private keys. These can be used to allow for access to remote git repositories.

## Known issues and limitations

- This add-on is, by default, configured for use with Hass.io Ingress. If you
  wish to access the add-on via a its own port directly, you can simply
  assign a port in the "Network" section of the add-on setting page.

## Support

Got questions?

You have several options to get them answered:

- The [Home Assistant Discord Chat Server][discord].
- The Home Assistant [Community Forum][forum].
- Join the [Reddit subreddit][reddit] in [/r/homeassistant][reddit]

In case you've found an bug, please [open an issue on our GitHub][issue].

[aarch64-shield]: https://img.shields.io/badge/aarch64-yes-green.svg
[amd64-shield]: https://img.shields.io/badge/amd64-yes-green.svg
[armhf-shield]: https://img.shields.io/badge/armhf-yes-green.svg
[armv7-shield]: https://img.shields.io/badge/armv7-yes-green.svg
[discord]: https://discord.gg/c5DvZ4e
[forum]: https://community.home-assistant.io
[i386-shield]: https://img.shields.io/badge/i386-yes-green.svg
[issue]: https://github.com/home-assistant/hassio-addons/issues
[reddit]: https://reddit.com/r/homeassistant
[repository]: https://github.com/hassio-addons/repository
[screenshot]: https://github.com/home-assistant/hassio-addons/raw/master/configurator/images/screenshot.png
[occu]: https://github.com/jens-maus/occu/
[hm-mod-rpi-pcb]: https://www.elv.ch/homematic-funkmodul-fuer-raspberry-pi-bausatz.html
[hmip-rufsb]: https://www.elv.ch/elv-homematic-ip-rf-usb-stick-hmip-rfusb-fuer-alternative-steuerungsplattformen-arr-bausatz.html
