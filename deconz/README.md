# Hass.io Core Add-on: deCONZ

Control a ZigBee network using ConBee or RaspBee hardware by Dresden Elektronik.

![Supports aarch64 Architecture][aarch64-shield] ![Supports amd64 Architecture][amd64-shield] ![Supports armhf Architecture][armhf-shield] ![Supports armv7 Architecture][armv7-shield] ![Supports i386 Architecture][i386-shield]

## About

You can use this add-on to check whether your configuration files are valid against the
new version of Home Assistant before you actually update your Home Assistant
installation. This add-on will help you avoid errors due to breaking changes,
resulting in a smooth update.

## Installation

The installation of this add-on is straightforward and easy to do.

1. Navigate in your Home Assistant frontend to **Hass.io** -> **Add-on Store**.
2. Find the "deCONZ" add-on and click it.
3. Click on the "INSTALL" button.

## How to use

### Using a RaspBee

If your are using RaspBee, you may need to edit the `config.txt` file in the root
of your SD card in order for your RaspBee to be recognized and assigned a device name.

Add following to your `config.txt`:

```txt
enable_uart=1
dtoverlay=pi3-miniuart-bt
```

### Configure the add-on

The add-on needs to know where your ConBee/RaspBee can be found, and therefore,
you'll need to configure the add-on to point to the right device.

If you're using Hass.io you may find the correct value for this on the
`Hass.io -> System -> Host system -> Hardware` page.

1. Replace **null** in the `device` option in the add-on configuration and specify
   the device name in quotes: (e.g. `"/dev/ttyUSB0"`, `"/dev/ttyAMA0"`, or `"/dev/ttyACM0"`).
2. Click on "SAVE" to save the add-on configuration.
3. Start the add-on.

After installing and starting this add-on, access the deCONZ WebUI ("Phoscon")
with "WEB UI" button.

## Configuring the Home Assistant deCONZ Component

By default, Home Assistant has the `discovery` component enabled, which
automatically discovers this add-on.

Navigate to **Configuration** -> **Integrations** page after starting this
add-on to configure the deCONZ component.

In case you don't have `discovery` enabled on your Home Assistant instance,
follow these instructions to configure the deCONZ component:

<https://home-assistant.io/components/deconz/>

## Migrating to this Add-on

To migrate deCONZ to Hass.io and this add-on, backup your deCONZ config via the
Phoscon WebUI, then restore that config after installing/reinstalling.

**_You must perform these steps or your Light, Group names and other data will be lost!_**

However, your ZigBee devices will remain paired to your ConBee or RaspBee hardware.

## Configuration

Add-on configuration:

```json
{
  "device": "/dev/ttyAMA0"
}
```

### Option: `device` (required)

The device address of your ConBee/RaspBee.

If you're using Hass.io you may find the correct value for this on the
`Hass.io -> System -> Host system -> Hardware` page.

In most cases this is one of the following:

- `"/dev/ttyUSB0"`
- `"/dev/ttyAMA0"`
- `"/dev/ttyACM0"`

## Known issues and limitations

- Use at least 2.5A power supply for your Raspberry Pi!
  This avoids strange behavior when using this add-on.

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
[armv7-shield]: https://img.shields.io/badge/armv7-no-red.svg
[discord]: https://discord.gg/c5DvZ4e
[forum]: https://community.home-assistant.io
[i386-shield]: https://img.shields.io/badge/i386-no-red.svg
[issue]: https://github.com/home-assistant/hassio-addons/issues
[reddit]: https://reddit.com/r/homeassistant
[repository]: https://github.com/hassio-addons/repository
