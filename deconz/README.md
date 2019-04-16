# deCONZ

Add-on to allow Home Assistant to control a ZigBee network with Conbee or RaspBee hardware by Dresden Elektronik.

## First Steps

If using RaspBee, you may need to edit `config.txt` on the root of your SD card for your RaspBee to be recognized and assigned a device name. Add folling information to `config.txt`:

```
enable_uart=1
dtoverlay=pi3-miniuart-bt
```

Before starting the add-on for the first time after installing, in the add-on config you must specify the device name that has been assigned to your RaspBee/Conbee as the `device`. Replace **null** and specify the device name in quotes (e.g. "/dev/ttyUSB0" or "/dev/ttyAMA0"). The other config options have sensible defaults that should not need to be changed unless you are debugging.

Use a 2.5A power supply for your Raspberry Pi 3! Strange behaviour with this Add-on may otherwise result.

## Adding ZigBee Devices

After installing and starting this addon in Hass.io, access the deCONZ WebUI ("Phoscon") with WebUI button.

## Configuring the Home Assistant deCONZ Component

If `discovery:` is enabled in configuration.yaml, navigate to the Configuration - Integrations page after starting this Add-on to configure the deCONZ component.

If `discovery:` is not enabled, follow these instructions to configure the deCONZ component: https://home-assistant.io/components/deconz/.

## Migrating to this Add-on

To migrate deCONZ to Hass.io and this Add-on (or before uninstalling/reinstalling this Add-on), backup your deCONZ config via the Phoscon WebUI, then restore that config after installing/reinstalling. _You must perform these steps or your Light and Group names and other data will be lost!_ (However, your ZigBee devices will remain paired to your Conbee or RaspBee hardware.)
