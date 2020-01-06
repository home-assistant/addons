# Changelog

## 5.1

- Add LEDVANCE / OSRAM otau firmware downloader, respecting max 10 DL per minute Ratelimits

## 5.0

- Fix additional gateway visible on Phoscon login on Ingress
- Fix Phoscon device scanning/probing triggering IP bans
- Fix redirect to login page when Phoscon session expires
- Fix incorrect manifest request from Phoscon frontend
- Fix and improve API key handling with Hass.io discovery
- Change Hass.io discovery to use add-on IP instead of hostname
- Improve Phoscon discovery to work different and faster with Ingress
- Add Websocket support to Ingress for instant and snappy UI updates
- Re-instate direct access capabilities to the Phoscon/deCONZ API

_Please note: This release works best with Home Assistant 0.103.4 or newer,
that release contains fixes/optimizations for the add-on as well._

## 4.1

- Change internal API port back to 40850, to prevent issue with discovery

## 4.0

- Bump deCONZ to 2.05.72
- Add support for Hass.io Ingress
- Improve auto discovery handling
- Remove support for UPnP

## 3.9

- Adds support for enabling UPnP
- Improve waiting for udev devices mechanism

## 3.8

- Bump deCONZ to 2.05.71

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
