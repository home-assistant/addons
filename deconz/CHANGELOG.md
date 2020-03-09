# Changelog

## 5.3.2

- Bump deCONZ to 2.05.75

Phoscon App

- Support iCasa ICZB-KPD12, ICZB-KPD14S and ICZB-KPD18S in switch editor.
- Show Xiaomi light sensor in devices sensors page.
- Show Xiaomi WXCJKG11LM, WXCJKG12LM, WXCJKG13LM and QBKG11LM on devices switches page.
- Show Bitron 902010/23 remote control on devices switches page.
- Fix bug that gateway settings page did show an offline page.
- Fix that the gateway itself did show up in the devices lights overview.

Under the hood

- Optimize consumption polling for smart plugs 6ed215
- Support Samsung/Centralite smart outlet 4d4ce4
- Support Bitron remote #2392
- Support Hue smart button #2077
- Support Sercomm / Telstra SZ-ESW01-AU smart plug eb29d8
- Improve reporting of GS SKHMP30-I1 smart plug c08051
- Support SmartThings 2014 motion sensor 1f127c
- Support innr RC 110 and for iCasa Remote #2541 241bad
- Support setting state.bri for Xiaomi Aqara curtain motor B1 #1654 dbc214
- Improve window covering code 35aad7
- Improve Aqara Opple switches support #2531
- Improve group handling of IKEA Trådfri remote control and wireless dimmer with Zigbee 3.0 firmware 46d491 #2485
- Correct power value for Samsung/Centralite smart outlet d7fbeb
- Correct RMS voltage value for Develco EMIZB-132 1ae2fe
- Improve measurement units and reporting for Sercomm / Telstra SZ-ESW01-AU smart plug cf2e18 cc198d
- Remove state.bri attribute for 3A in-wall switch fc53c0
- Remove config.battery attribute for Xiaomi smart plugs c63e9b
- Fix newer model Heiman conbustable gas sensor exposed as ZHACarbnMonoxide instead ZHAFire #627 bb1f9e
- Add sanity checks for valid RuleConditions aef786
- CLIPDaylightOffset sensor, support value referring to other sensor 7ad1e3
- Add siren support for Develco heat and water leak sensor 39ecf9
- Add binding / attribute reporting for various Heiman devices 5f60db
- Refactor handling of Hue dimmer, Hue button and Lutron Aurora switches ce4a6a
- New firmware version 0x26350500 for RaspBee I and ConBee I to improve route maintenance #1261 deCONZ_Rpi_0x26350500.bin.GCF

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
