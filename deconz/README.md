# deCONZ

Add-on to allow Home Assistant to control a ZigBee network with Conbee or RaspBee hardware by Dresden Elektronik.

## First Steps

If using RaspBee, you may need to edit config.txt on the root of your SD card for your RaspBee to be recognized and assigned a device name: see https://github.com/marthoc/hassio-addons/blob/master/deconz/RASPBEE-SETUP.md.

Before starting the add-on for the first time after installing **or upgrading**, in the add-on config you must specify the device name that has been assigned to your RaspBee/Conbee as the "deconz_device". Replace **null** and specify the device name in quotes (e.g. "/dev/ttyUSB0" or "/dev/ttyAMA0"). The other config options have sensible defaults that should not need to be changed unless you are debugging.

## Adding ZigBee Devices

After installing and starting this addon in Hass.io, access the deCONZ WebUI ("Phoscon") to add ZigBee devices: http://hassio.local:8080

The default username/password is delight/delight.

## Configuring the Home Assistant deCONZ Component

If `discovery:` is enabled in configuration.yaml, navigate to the Configuration - Integrations page after starting this Add-on to configure the deCONZ component.

If `discovery:` is not enabled, follow these instructions to configure the deCONZ component: https://home-assistant.io/components/deconz/.

Raise any issues with this Add-on as an issue at https://github.com/marthoc/hassio-addons.

## Firmware Upgrades

You can upgrade the firmware of your RaspBee / Conbee device by following the instructions here: https://github.com/marthoc/hassio-addons/blob/master/deconz/FIRMWARE-UPGRADE.md. 

## Important!!

This Add-on's version number tracks deCONZ releases from Dresden Elektronik; changes to this Add-on's base image and settings may be made between deCONZ releases and incorporated when a new deCONZ version is released. A list of important/relevant changes is available at: https://github.com/marthoc/hassio-addons/blob/master/deconz/CHANGELOG.md.

Use a 2.5A power supply for your Raspberry Pi 3! Strange behaviour with this Add-on may otherwise result.

## Migrating to this Add-on

To migrate deCONZ to Hass.io and this Add-on (or before uninstalling/reinstalling this Add-on), backup your deCONZ config via the Phoscon WebUI, then restore that config after installing/reinstalling. _You must perform these steps or your Light and Group names and other data will be lost!_ (However, your ZigBee devices will remain paired to your Conbee or RaspBee hardware.)
