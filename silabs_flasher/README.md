# Home Assistant Add-on: Silicon Labs Flasher Add-on

Silicon Labs Flasher add-on to flash Silicon Labs based radios.

By default this add-on flashes the firmware to use Zigbee (Silicon
Labs EmberZNet Zigbee stack).

## Add-on configuration

Configuration	| Description:
--- | ---
Device (mandatory) | Serial service where the Silicon Labs radio is attached
Baudrate | Serial port baudrate (depends on firmware)
Flow_control | If hardware flow control should be enabled (depends on firmware)
Firmware_url | Custom URL to flash firmware from. 

Firmware for SkyConnect and Home Assistant Yellow can be found here: https://github.com/NabuCasa/silabs-firmware

**Note:** Make sure to use the Raw URL from GitHub:

<img src="https://github.com/home-assistant/addons/assets/5879533/65fe8364-317d-4300-b0d1-502fe72306db" width="400">

https://github.com/NabuCasa/silabs-firmware/raw/main/EmberZNet/NabuCasa_Yellow_EZSP_v6.10.3.0_PA32_ncp-uart-hw_115200_ext.gbl

Failing to provide a valid URL will result in the following error: ```Error: '/root/firmware.gbl' does not appear to be a valid GBL image: ValidationError('Image is truncated: tag value is cut off')```

**NOTE:** Make sure no other add-on or integration is using the radio. In
particular disable the Zigbee Home Automation integration and the Silicon Labs
Multiprotocol add-on.

![Supports aarch64 Architecture][aarch64-shield]
![Supports amd64 Architecture][amd64-shield]
![Supports armhf Architecture][armhf-shield]
![Supports armv7 Architecture][armv7-shield]
![Supports i386 Architecture][i386-shield]

## About

This add-on allows you to flash firmwares using the Gecko Bootloader file format
(gbl). By default it comes with firmware for Home Assistant SkyConnect and
Home Assistant Yellow to flash Zigbee.

[aarch64-shield]: https://img.shields.io/badge/aarch64-yes-green.svg
[amd64-shield]: https://img.shields.io/badge/amd64-yes-green.svg
[armhf-shield]: https://img.shields.io/badge/armhf-yes-green.svg
[armv7-shield]: https://img.shields.io/badge/armv7-yes-green.svg
[i386-shield]: https://img.shields.io/badge/i386-yes-green.svg
