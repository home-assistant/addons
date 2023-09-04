# Home Assistant Add-on: HomeMatic

#### WARNING: This add-on is considered to be obsolete/retired in favor of the much more advanced third-party [RaspberryMatic CCU](https://github.com/jens-maus/RaspberryMatic/tree/master/home-assistant-addon) add-on for running a HomeMatic/homematicIP smart home central within HomeAssistant. If you want to migrate to the new add-on, please make sure to update to the latest version of this old "HomeMatic CCU" add-on first and then use the WebUI-based backup routines to export a `*.sbk` config backup file which you can then restore in the new "RaspberryMatic CCU" add-on afterwards (cf. [RaspberryMatic Documentation](https://github.com/jens-maus/RaspberryMatic/wiki/Installation-HomeAssistant))

HomeMatic central based on OCCU.

![Supports aarch64 Architecture][aarch64-shield] ![Supports amd64 Architecture][amd64-shield] ![Supports armhf Architecture][armhf-shield] ![Supports armv7 Architecture][armv7-shield] ![Supports i386 Architecture][i386-shield]

## About

This add-on allows you to control your HomeMatic devices so they can be
integrated into Home Assistant. It is based on the
[HomeMatic Open Central Control Unit (OCCU) SDK][occu].

Note: Requires a [HM-MOD-RPI-PCB][hm-mod-rpi-pcb] or [HmIP-RFUSB][hmip-rufsb]
to interface with your devices.

## Features

- Your Raspberry Pi is your HomeMatic control center!
- WebUI ReGaHss with ingress support
- Firmware updates


[aarch64-shield]: https://img.shields.io/badge/aarch64-no-red.svg
[amd64-shield]: https://img.shields.io/badge/amd64-no-red.svg
[armhf-shield]: https://img.shields.io/badge/armhf-no-red.svg
[armv7-shield]: https://img.shields.io/badge/armv7-yes-green.svg
[i386-shield]: https://img.shields.io/badge/i386-yes-green.svg
[occu]: https://github.com/jens-maus/occu/
[hm-mod-rpi-pcb]: https://ch.elv.com/elv-homematic-komplettbausatz-funkmodul-fuer-raspberry-pi-hm-mod-rpi-pcb-fuer-smart-home-hausautomation-142141
[hmip-rufsb]: https://ch.elv.com/elv-homematic-ip-arr-bausatz-rf-usb-stick-fuer-alternative-steuerungsplattformen-hmip-rfusb-fuer-smart-home-hausautomation-152306
