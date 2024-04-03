# Home Assistant Add-on: Silicon Labs Flasher Add-on

Silicon Labs Flasher add-on to flash Silicon Labs based radios.

By default this add-on flashes the firmware to use Zigbee (Silicon
Labs EmberZNet Zigbee stack).

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
(gbl). By default it comes with firmware for Home Assistant SkyConnect/ZBT-1 and
Home Assistant Yellow to flash Zigbee.

[aarch64-shield]: https://img.shields.io/badge/aarch64-yes-green.svg
[amd64-shield]: https://img.shields.io/badge/amd64-yes-green.svg
[armhf-shield]: https://img.shields.io/badge/armhf-yes-green.svg
[armv7-shield]: https://img.shields.io/badge/armv7-yes-green.svg
[i386-shield]: https://img.shields.io/badge/i386-yes-green.svg