# Changelog

## 3.7

- Bump deCONZ to 2.05.70

## 3.6

- Bump deCONZ to 2.05.69
- Update wiringPi to latest (2.52)

## 3.5

- Add support for native aarch64

## 3.4

- Cleanup some udev rules
- Use new Hass.io API for device reload

## 3.3

- Fix relative to absolut device lookup

## 3.2

- Bump deCONZ to 2.05.67
- Add own udev service
- Monitoring only deCONZ process

## 3.1

- Improves VNC desktop name
- Adds check if VNC port is free to use
- Documents firmware upgrade process and caveats

## 3.0

- Adds support for accessing deCONZ via VNC
- Adds debug output control options

## 2.7

- Bump deCONZ to 2.05.66

## 2.6

- Adding missing dependencies of deconz
- Create otau storage directory on start

## 2.5

- Corrects error in installation instructions steps

## 2.4

- Bump deCONZ to 2.05.65

## 2.3

- Rewrite of README
- Fixes add-on URL

## 2.2

- Bump deCONZ to 2.05.64

## 2.1

- Bump deCONZ to 2.05.63
- Remove Ingress support / Don't run well with SSL

## 2.0

- Add support for Home Assistant Add-on integration
- Add Ingress support

**WARNING:** This version change the network modus to host network that it works with mobile apps from deCONZ. That mean you need remove the old integration and connect it again. 2min after first Startup, the Add-on provides its own Discovery details to Home Assistant.

## 1.4

- Bump deCONZ to 2.05.59
- Remove the fake aarch64 version in favor of new arch selector

## 1.3

- Bump deCONZ to 2.05.58
- Support now Firmware updates over the Phoscon UI

## 1.2

- Bump deCONZ to 2.05.57

## 1.1

- Bump deCONZ to 2.05.55

## 1.0

- Initial release as Home Assistant core Add-on
- Bump deCONZ to 2.05.54
