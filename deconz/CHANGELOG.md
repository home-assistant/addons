# Changelog

## 5.3.4

- Bump deCONZ to 2.05.77

## 5.3.3

- Bump deCONZ to 2.05.76

## 5.3.2

- Bump deCONZ to 2.05.75

## 5.3.1

- Increase wait time for show device

## 5.3.0

- Bump deCONZ to 2.05.74

## 5.2.0

- Bump deCONZ to 2.05.73
- Small adjustments to NGINX configuration

## 5.1.0

- Add LEDVANCE / OSRAM otau firmware downloader, respecting max 10 DL per minute Ratelimits

## 5.0.0

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

## 4.1.0

- Change internal API port back to 40850, to prevent issue with discovery

## 4.0.0

- Bump deCONZ to 2.05.72
- Add support for Hass.io Ingress
- Improve auto discovery handling
- Remove support for UPnP
