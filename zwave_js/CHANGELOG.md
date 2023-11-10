# Changelog

## 0.3.0

### Features

- Add-On: Add `disable_controller_recovery` configuration option. When enabled, the driver will not attempt to automatically recover from an unresponsive controller and will instead either let the controller recover on its own or wait for the user to restart the add-on to attempt recovery. This is an advanced configuration option that should not be adjusted in most cases and is therefore hidden from the default view.

### Bug fixes

- Z-Wave JS: Ensure the default Basic CC values are only exposed if they should be
- Z-Wave JS: Auto-remove failed SmartStart nodes when bootstrapping times out
- Z-Wave JS: Improve how unresponsive controllers are handled

### Config file changes

- Tweak Heatit Z-TRM6 options
- Add Ring Alarm Panic Button Gen2
- Update fingerprints for Vesternet device

### Detailed changelogs

- [Z-Wave JS 12.3.0](https://github.com/zwave-js/node-zwave-js/releases/tag/v12.3.0)

## 0.2.1

### Config file changes

- Treat Binary Switch Set and Thermostat Mode Set as reports for SRT321 HRT4-ZW
- Override supported Thermostat modes for Eurotronics Spirit TRV
- Correct firmware warnings for Zooz controllers
- Correct overridden thermostatMode metadata for ZME_FT
- Add MCOHome C521/C621 shutters, fix C321, make shutters consistent
- Correct product id for Fakro ZWS12
- add PM-B400ZW-N
- Ensure kWh is written consistently in parameter units

### Detailed changelogs

- [Z-Wave JS 12.2.3](https://github.com/zwave-js/node-zwave-js/releases/tag/v12.2.3)
- [Z-Wave JS 12.2.2](https://github.com/zwave-js/node-zwave-js/releases/tag/v12.2.2)
- [Z-Wave JS 12.2.1](https://github.com/zwave-js/node-zwave-js/releases/tag/v12.2.1)
- [Z-Wave JS Server 1.33.0](https://github.com/zwave-js/zwave-js-server/releases/tag/1.33.0)

## 0.2.0

### Features

- Add-on: Add `safe_mode` configuration option to put Z-Wave network in safe mode. This can be used help with troubleshooting network issues, such as being unable to start it, but will likely slow down your network and should therefore be used sparingly. This is an advanced configuration option that should not be adjusted in most cases and is therefore hidden from the default view.
- Add-on: Switch to [semantic versioning](https://semver.org/). With this change, major version changes to the addon will now reflect e.g. a major version release of Z-Wave JS or a significant change to the add-on structure. This should help users better understand the potential impact of an upgrade.

### Bug fixes

- Z-Wave JS: Includes several more fixes and workarounds for the problematic interaction between some controller firmware bugs and the automatic controller recovery introduced in the `v12` release

### Config file changes

- Add NEO Cool Cam Repeater
- Increase report timeout for Aeotec Multisensor 6 to 2s

### Detailed changelogs

- [Z-Wave JS 12.2.0](https://github.com/zwave-js/node-zwave-js/releases/tag/v12.2.0)
- [Z-Wave JS Server 1.32.2](https://github.com/zwave-js/zwave-js-server/releases/tag/1.32.2)

## 0.1.98

### Bug fixes

- Z-Wave JS: Fixed an issue with multi-target firmware updates that prevented updates from being applied correctly

### Config file changes

Almost 1000 device configuration files have been reworked to be more consistent, mostly affecting device labels, parameter labels, descriptions and predefined options. After updating, you should expect to see several notifications for changed device configurations, prompting you to re-interview the affected nodes. Unless the device is mentioned below, there's no need to do this immediately.

- Add parameter 26 to Inovelli VZW31-SN
- Always set time for Namron 16A thermostats as UTC
- Add Alloy (Zipato) devices
- Parameter 21 of Inovelli VZW31-SN is readonly
- Add Shelly Wave Shutter
- Add Eurotronic Comet Z (700 series)
- Add params 7, 18, 19 to Zooz ZEN71 FW 10.20
- Add Qubino Shades Remote Controller
- Add fingerprint for new MH8-FC version, add new option for param 1
- Add Hank HKZW-SO08
- Add link to manual of Honeywell T6 Pro Thermostat

### Detailed changelogs

- [Z-Wave JS 12.1.0](https://github.com/zwave-js/node-zwave-js/releases/tag/v12.1.0)
- [Z-Wave JS 12.1.1](https://github.com/zwave-js/node-zwave-js/releases/tag/v12.1.1)

## 0.1.97

### Bug fixes

- Z-Wave JS: Fixed a crash that could happen while logging dropped sensor readings.
- Z-Wave JS: Change the default timeout to handle slow 500 series controllers.

### Config file changes

- Treat Basic Set as events for TKB TZ35S/D and TZ55S/D
- Add Zooz ZAC38 Range Extender
- Corrected the label of the notification event `0x0a` to be `Emergency Alarm`

### Detailed changelogs

- [Z-Wave JS 12.0.4](https://github.com/zwave-js/node-zwave-js/releases/tag/v12.0.4)

## 0.1.96

### Bug fixes

- Add-on: Make `soft_reset` configuration option optional since, when required, it breaks add-on installations done through the `zwave_js` integration.

## 0.1.95

### Bug fixes

- Z-Wave JS: Fixes or works around multiple issues with 500 series controllers that could trigger the unresponsive controller detection in Z-Wave JS 12 in situations where it was not necessary, causing restart loops.


### Bug fixes

- [Z-Wave JS 12.0.3](https://github.com/zwave-js/node-zwave-js/releases/tag/v12.0.3)

## 0.1.94

### Features

- Add-on: Add a `soft_reset` configuration option to choose how to handle soft-reset functionality for 500 series controllers.
- Add-on: Extend timeout from 3 seconds to 30 to give Z-Wave JS more time to commit things to disk.

### Bug fixes

- Z-Wave JS: The workaround from v12.0.0 for the 7.19.x SDK bug was not working correctly when the command that caused the controller to get stuck could be retried. This has now been fixed.
- Z-Wave JS: Ignore when a node reports Security S0/S2 CC to have version 0 (unsupported) although it is using that CC

### Config file changes
- Add Shelly to manufacturers
- Add Shelly Wave 1, Wave 2PM, update Wave 1PM association labels
- Add Sunricher SR-ZV2833PAC

### Detailed changelog

- [Z-Wave JS 12.0.1](https://github.com/zwave-js/node-zwave-js/releases/tag/v12.0.1)
- [Z-Wave JS 12.0.2](https://github.com/zwave-js/node-zwave-js/releases/tag/v12.0.2)

## 0.1.93

### Bug fixes

- Z-Wave JS Server: For users that have opted in to data collection in their Home Assistant Z-Wave configuration, a missing return caused the server to try to soft reset the controller during Home Assistant startup for Home Assiststant versions 2023.9.x or less. This has now been resolved.

### Detailed changelog

- [Z-Wave JS Server 1.32.1](https://github.com/zwave-js/zwave-js-server/releases/tag/1.32.1)

## 0.1.92

### Bug fixes

- Add-on: Revert change to stop rebuilding @serialport/bindings-cpp from source as the problem is fixed on some CPU platforms but not all

## 0.1.91

### Breaking changes

- Z-Wave JS: Firmware updates may no longer work properly in Home Assistant versions 2023.9.x and earlier due to a breaking change upstream that couldn't be made backward compatible, but will work once again starting in 2023.10.0. This breaking change ultimately improves firmware updates, as checking for updates no longer requires communication with the device, therefore reducing the risk of corrupting manufacturer information. This also means that updates for battery-powered devices can be detected without waking up the devices.

### Features

- Z-Wave JS: Unresponsive controllers are now detected and automatically restarted if possible.
- Z-Wave JS: Battery-powered devices are sent back to sleep after 250 ms with no command (down from 1000 ms). This should result in significant battery savings for devices that frequently wake up.
- Add-on: We no longer rebuild the @serialport/bindings-cpp package from source.

### Bug fixes

- Z-Wave JS: A bug in the 7.19.x SDK has surfaced where the controller gets stuck in the middle of a transmission. Previously, this would go unnoticed because the failed commands would cause the nodes to be marked dead until the controller finally recovered. Since v11.12.0, however, Z-Wave JS would consider the controller jammed and retry the last command indefinitely. This situation is now detected, and Z-Wave JS attempts to recover by soft resetting the controller when this happens.
- Z-Wave JS: Fixed an issue where supporting controllers would no longer be automatically restarted after failing to do so once.
- Z-Wave JS: Devices that send notifications from endpoints, like Aeotec Wallmote, are now properly supported.

### Config file changes

- Add warnings about broken controller firmware versions
- Add Heatit Z-Water 2
- Add Shelly Wave 1PM
- Add Heatit Z-TRM6
- Increase poll delay for ZW500D
- Add fingerprint for Simon IO Master Roller Blind
- Add HOPPE eHandle ConnectSense
- Add parameters to Zooz ZEN17 from firmware 1.30
- Update Zooz ZEN32 config to the latest firmware, include 800 series

### Detailed changelogs

- [Z-Wave JS 11.14.3](https://github.com/zwave-js/node-zwave-js/releases/tag/v11.14.3)
- [Z-Wave JS 12.0.0](https://github.com/zwave-js/node-zwave-js/releases/tag/v12.0.0)
- [Z-Wave JS Server 1.32.0](https://github.com/zwave-js/zwave-js-server/releases/tag/1.32.0)

## 0.1.90

### Bug fixes

- Z-Wave JS: Fixed an issue causing commands that have previously been moved to the wakeup queue for sleeping nodes to no longer be handled correctly on wakeup and block the send queue for an extended amount of time

### Detailed changelogs

- [Z-Wave JS 11.14.1](https://github.com/zwave-js/node-zwave-js/releases/tag/v11.14.1)
- [Z-Wave JS 11.14.2](https://github.com/zwave-js/node-zwave-js/releases/tag/v11.14.2)

## 0.1.89

### Features

- Z-Wave JS: Optimized the order of node communication during startup to ensure responsive nodes are ready first

### Bug fixes

- Z-Wave JS: The start/stop time and date values in `Schedule Entry Lock` CC commands are now validated
- Z-Wave JS: Fixed an issue where `hasDeviceConfigChanged` would return the opposite of what it should, triggering repair issues for users on HA version >= 2023.9.0b0.

### Config file changes

- Delay value refresh for ZW500D
- Update several Zooz devices to their 800 series revisions
- Extend version range for Vesternet VES-ZW-DIM-001

### Detailed changelogs

- [Z-Wave JS 11.14.0](https://github.com/zwave-js/node-zwave-js/releases/tag/v11.14.0)

## 0.1.88

### Features

- Z-Wave JS: Applications can now report on controller status
- Z-Wave JS Server: Added support for controller identify event

### Bug fixes

- Z-Wave JS: Fixed a regression from v11.10.1 where the controller's firmware version was not fully queried
- Z-Wave JS: Change order of commands so the startup does not fail when a controller is already set to use 16-bit node IDs and soft-reset is disabled
- Z-Wave JS: Soft-reset is now always enabled on 700+ series controllers 
- Z-Wave JS: Queried user codes and their status are now preserved during re-interview when they won't be re-queried automatically
- Z-Wave JS: Fixed an issue where nodes were being marked as dead because the controller couldn't transmit.
- Z-Wave JS: Fixed an issue where 700 series controllers were not soft-reset after NVM backup when soft-reset was disabled via config
- Z-Wave JS: Discard Meter CC and Multilevel Sensor CC reports when the node they supposedly come from does not support them
- Z-Wave JS: Abort inclusion when a node with the same ID is already part of the network
- Z-Wave JS: Fixed a startup crash that happens when the controller returns an empty list of nodes
- Z-Wave JS: Fixed an issue where API calls would be rejected early or incorrectly resolved while the driver was still retrying a command to an unresponsive node
- Z-Wave JS: Fixed an issue where the controller would be considered jammed if it responds with a Fail status, even after transmitting

### Config file changes

- Disable Supervision for Kwikset HC620 to work around a device bug causing it to flood the network
- Add fingerprint for Ring Outdoor Contact Sensor
- Remove unnecessary endpoint functionality for CT100
- Correct reporting frequency parameter values for Sensative AB Strips Comfort / Drips Multisensor

### Detailed changelogs
- [Bump Z-Wave JS Server to 1.31.0](https://github.com/zwave-js/zwave-js-server/releases/tag/1.31.0)
- [Bump Z-Wave JS to 11.11.0](https://github.com/zwave-js/node-zwave-js/releases/tag/v11.11.0)
- [Bump Z-Wave JS to 11.12.0](https://github.com/zwave-js/node-zwave-js/releases/tag/v11.12.0)
- [Bump Z-Wave JS to 11.13.0](https://github.com/zwave-js/node-zwave-js/releases/tag/v11.13.0)
- [Bump Z-Wave JS to 11.13.1](https://github.com/zwave-js/node-zwave-js/releases/tag/v11.13.1)

## 0.1.87

### Bug fixes

- Z-Wave JS: Fixed a bug where firmware links that redirected to another URL were not supported
- Z-Wave JS: Change order of commands so the startup does not fail when a controller is already set to use 16-bit node IDs and soft-reset is disabled
- Z-Wave JS: Soft-reset is now always enabled on 700+ series controllers 
- Z-Wave JS: Queried user codes and their status are now preserved during re-interview when they won't be re-queried automatically


### Config file changes

- Add parameters 9-13 to Minoston MP21ZP / MP31ZP
- Add fingerprint to Yale YRD446-ZW2
- Add and update Yale Assure ZW3 series locks
- Remove unnecessary endpoint functionality for CT101

### Detailed changelogs

- [Bump Z-Wave JS to 11.10.0](https://github.com/zwave-js/node-zwave-js/releases/tag/v11.10.0)
- [Bump Z-Wave JS to 11.10.1](https://github.com/zwave-js/node-zwave-js/releases/tag/v11.10.1)

## 0.1.86

### Bug fixes

- Z-Wave JS: Fixed an issue where a delayed endpoint capability report could be associated with the wrong query
- Z-Wave JS: During NVM migration, some invalid/unexpected bytes in the 500 series NVM can now be corrected
- Z-Wave JS: Hide configuration values for Door Lock CC v4 functionality that is not supported by a lock
- Z-Wave JS: When a CC version query times out, the CC version is now actually assumed to be 1
- Z-Wave JS: Recover from Security S2 collisions in a common scenario where nodes send a supervised command at the same time Z-Wave JS is trying to control them
- Z-Wave JS: During NVM migration, an incorrect flag for "on other network" is now automatically corrected instead of raising an error
- Z-Wave JS: Fixed an issue where turning on a Multilevel Switch with transition duration could update the currentValue to an illegal value
- Z-Wave JS: Improve heuristic to refresh values from legacy nodes when receiving a node information frame
- Z-Wave JS: Fixed an issue where no control values were exposed for devices that do not support/advertise Version CC
- Z-Wave JS: Fixed a regression introduced in 11.9.1 that would sometimes cause the startup process to hang


### Config file changes

- Add Leviton RZM10-1L
- Force use of Multi Channel CC v1 for all versions of PE653
- Correct state after power failure for Minoston MP21Z/31Z
- Add Namron 4512757
- Preserve endpoint 0 for Zooz ZEN14 to toggle both outlets at once
- Correct value size for some Nortek PD300EMZ5-1 params that were previously swapped
- Add new MCOHome MH-S411/S412 models

### Detailed changelogs

- [Bump Z-Wave JS to 11.7.0](https://github.com/zwave-js/node-zwave-js/releases/tag/v11.7.0)
- [Bump Z-Wave JS to 11.8.0](https://github.com/zwave-js/node-zwave-js/releases/tag/v11.8.0)
- [Bump Z-Wave JS to 11.8.1](https://github.com/zwave-js/node-zwave-js/releases/tag/v11.8.1)
- [Bump Z-Wave JS to 11.9.0](https://github.com/zwave-js/node-zwave-js/releases/tag/v11.9.0)
- [Bump Z-Wave JS to 11.9.1](https://github.com/zwave-js/node-zwave-js/releases/tag/v11.9.1)
- [Bump Z-Wave JS to 11.9.2](https://github.com/zwave-js/node-zwave-js/releases/tag/v11.9.2)

## 0.1.85

### New features

- Z-Wave JS Server: Add support for inclusions that are started outside of Z-Wave JS Server
- Z-Wave JS Server: Add support for lastSeen property
- Z-Wave JS: Add support for identifying on request of other nodes
- Z-Wave JS: Improved auto-discovery of config parameters

### Bug fixes

- Z-Wave JS Server: Fix hard reset support in Z-Wave JS Server
- Z-Wave JS: Increased OTA update timeout, which can help with firmware updates in busy/unstable networks
- Z-Wave JS: Fixed a crash that could happen when including a device with an inclusion controller
- Z-Wave JS: Improved the automatic removal of factory-reset devices that are slow to leave the network
- Z-Wave JS: Devices that failed to join using SmartStart are now automatically removed
- Z-Wave JS: Fix an issue where Z-Wave JS could get stuck when removing a node from the network failed


### Config file changes

- Correct config parameters for Duwi ZW ESJ 300
- Add new FW3.6 parameters to Aeotec ZW141 Nano Shutter
- Add metadata to HANK Electronics Ltd. HKZW-SO01
- Hide Binary Switch CC in favor of Window Covering CC on iBlinds v3
- Remove unnecessary endpoints for RTC CT32
- Update Swidget devices to match their June 8th 2023 spec
- Add endpoint configuration parameters to SES 302
- Disable Window Covering CC for ZVIDAR Roller Blind
- Add missing product type to Aeotec Water Sensor 7 Basic ZWA018
- Override endpoint indizes for heatapp! floor
- Override schedule slot count for P-KFCON-MOD-YALE
- Override supported color channels for Zipato RGBW Bulb2
- Override supported thermostat modes for Z-Wave.me ZME_FT
- Add Heatit ZM Dimmer
- Add Heatit Z-HAN2
- Add Remotec ZXT-800
- Clarify Hand Button action for ZVIDAR Z-CM-V01 Smart Curtain Motor
- Add MCOHome MH-S220 FW 3.2
- Add another device ID for Switch IO On/Off Power Switch
- Add/fix params for Intermatic PE653
- Add ShenZhen Sunricher Technology Multisensor SR-ZV9032A-EU
- Add new fingerprint for Zooz ZST10-700
- Fix Zooz ZSE40 parameters 7 and 8
- Correct parameters of Zooz ZEN05
- Override supported setpoint types for Intermatic PE653
- Update Inovelli LZW31 parameter 52 for FW 1.54
- Add new product id to Fakro ZWS12
- Disable Supervision for NICE Spa IBT4ZWAVE
- Add variant of Inovelli NZW31T with manufacturer ID 0x015d
- Split and correct Minoston MP21Z/MP31Z/MP21ZP/MP31ZP config files
- Add EVA LOGIK (NIE Tech) ZKS31 Rotary Dimmer

### Detailed changelogs

- [Bump Z-Wave JS Server to 1.29.0](https://github.com/zwave-js/zwave-js-server/releases/tag/1.29.0)
- [Bump Z-Wave JS Server to 1.29.1](https://github.com/zwave-js/zwave-js-server/releases/tag/1.29.1)
- [Bump Z-Wave JS Server to 1.30.0](https://github.com/zwave-js/zwave-js-server/releases/tag/1.30.0)
- [Bump Z-Wave JS to 10.23.4](https://github.com/zwave-js/node-zwave-js/releases/tag/v10.23.4)
- [Bump Z-Wave JS to 10.23.5](https://github.com/zwave-js/node-zwave-js/releases/tag/v10.23.5)
- [Bump Z-Wave JS to 10.23.6](https://github.com/zwave-js/node-zwave-js/releases/tag/v10.23.6)
- [Bump Z-Wave JS to 11.0.0](https://github.com/zwave-js/node-zwave-js/releases/tag/v11.0.0)
- [Bump Z-Wave JS to 11.1.0](https://github.com/zwave-js/node-zwave-js/releases/tag/v11.1.0)
- [Bump Z-Wave JS to 11.2.0](https://github.com/zwave-js/node-zwave-js/releases/tag/v11.2.0)
- [Bump Z-Wave JS to 11.3.0](https://github.com/zwave-js/node-zwave-js/releases/tag/v11.3.0)
- [Bump Z-Wave JS to 11.4.0](https://github.com/zwave-js/node-zwave-js/releases/tag/v11.4.0)
- [Bump Z-Wave JS to 11.4.1](https://github.com/zwave-js/node-zwave-js/releases/tag/v11.4.1)
- [Bump Z-Wave JS to 11.4.2](https://github.com/zwave-js/node-zwave-js/releases/tag/v11.4.2)
- [Bump Z-Wave JS to 11.5.0](https://github.com/zwave-js/node-zwave-js/releases/tag/v11.5.0)
- [Bump Z-Wave JS to 11.5.1](https://github.com/zwave-js/node-zwave-js/releases/tag/v11.5.1)
- [Bump Z-Wave JS to 11.5.2](https://github.com/zwave-js/node-zwave-js/releases/tag/v11.5.2)
- [Bump Z-Wave JS to 11.5.3](https://github.com/zwave-js/node-zwave-js/releases/tag/v11.5.3)
- [Bump Z-Wave JS to 11.6.0](https://github.com/zwave-js/node-zwave-js/releases/tag/v11.6.0)

## 0.1.84

### Bug fixes

- Fixed an issue which could cause temperature to be shown in Celsius instead of Fahrenheit
- Fixed an issue which could cause devices to be incorrectly considered to be awake
- Verify state change for barrier devices without support for Supervision CC instead of assuming commands to succeed

### Config file changes

- Correct config parameters for Duwi ZW ESJ 300

### Detailed changelogs

- [Bump Z-Wave JS to 10.23.0](https://github.com/zwave-js/node-zwave-js/releases/tag/v10.23.0)
- [Bump Z-Wave JS to 10.23.1](https://github.com/zwave-js/node-zwave-js/releases/tag/v10.23.1)
- [Bump Z-Wave JS to 10.23.2](https://github.com/zwave-js/node-zwave-js/releases/tag/v10.23.2)

## 0.1.83

### Bug fixes

- Fixed an issue introduced in Z-Wave JS `10.21.0` where some optimistic value updates would no longer happen after successful multicast commands

### Detailed changelogs

- [Bump Z-Wave JS to 10.22.3](https://github.com/zwave-js/node-zwave-js/releases/tag/v10.22.3)

## 0.1.82

### Bug fixes

- Fixed a crash scenario
- Fixed an issue that caused device values to stop updating

### Config file changes

- Add LG U+ smart switches
- Add/correct config files for iSurpass J1825
- Added another variant of Kwikset 914C
- Add Dawon PM-S140-ZW, PM-S340-ZW and KR frequencies

### Detailed changelogs

- [Bump Z-Wave JS to 10.22.1](https://github.com/zwave-js/node-zwave-js/releases/tag/v10.22.1)
- [Bump Z-Wave JS to 10.22.2](https://github.com/zwave-js/node-zwave-js/releases/tag/v10.22.2)

## 0.1.81

### Bug fixes

- Fixed several crashes
- Expose some device functionality that would previously be hidden as redundant
- Auto-discovered config parameters (for new devices) can now be edited
- Properly support config parameters above number 255
- Optimized the config parameter queries during the interview to take much less time in many cases
- Some minor changes to better comply with the Z-Wave specification

### Config file changes

- Add configuration for Zooz ZEN53, 54, 55
- Extend version range for Vesternet VES-ZW-HLD-016
- Add 700 series variant of SimonTech Roller Blind
- Updated instructions for Leviton VRS15 and ZW15R

### Detailed changelogs

- [Bump Z-Wave JS to 10.21.0](https://github.com/zwave-js/node-zwave-js/releases/tag/v10.21.0)
- [Bump Z-Wave JS to 10.20.0](https://github.com/zwave-js/node-zwave-js/releases/tag/v10.20.0)
- [Bump Z-Wave JS to 10.19.0](https://github.com/zwave-js/node-zwave-js/releases/tag/v10.19.0)
- [Bump Z-Wave JS to 10.18.0](https://github.com/zwave-js/node-zwave-js/releases/tag/v10.18.0)
- [Bump Z-Wave JS to 10.17.1](https://github.com/zwave-js/node-zwave-js/releases/tag/v10.17.1)

## 0.1.80

- [Bump Z-Wave JS to 10.17.0](https://github.com/zwave-js/node-zwave-js/releases/tag/v10.17.0)

## 0.1.79

- [Bump Z-Wave JS to 10.16.0](https://github.com/zwave-js/node-zwave-js/releases/tag/v10.16.0)

## 0.1.78

- [Bump Z-Wave JS Server to 1.28.0](https://github.com/zwave-js/zwave-js-server/releases/tag/1.28.0)
- [Bump Z-Wave JS to 10.15.0](https://github.com/zwave-js/node-zwave-js/releases/tag/v10.15.0)
- [Bump Z-Wave JS to 10.14.1](https://github.com/zwave-js/node-zwave-js/releases/tag/v10.14.1)
- [Bump Z-Wave JS to 10.14.0](https://github.com/zwave-js/node-zwave-js/releases/tag/v10.14.0)
- [Bump Z-Wave JS to 10.13.0](https://github.com/zwave-js/node-zwave-js/releases/tag/v10.13.0)

## 0.1.77

- [Bump Z-Wave JS Server to 1.27.0](https://github.com/zwave-js/zwave-js-server/releases/tag/1.27.0)
- [Bump Z-Wave JS to 10.12.0](https://github.com/zwave-js/node-zwave-js/releases/tag/v10.12.0)
- [Bump Z-Wave JS to 10.11.1](https://github.com/zwave-js/node-zwave-js/releases/tag/v10.11.1)
- [Bump Z-Wave JS to 10.11.0](https://github.com/zwave-js/node-zwave-js/releases/tag/v10.11.0)

## 0.1.76

- [Bump Z-Wave JS Server to 1.26.0](https://github.com/zwave-js/zwave-js-server/releases/tag/1.26.0)
- [Bump Z-Wave JS to 10.10.0](https://github.com/zwave-js/node-zwave-js/releases/tag/v10.10.0)

## 0.1.75

- [Bump Z-Wave JS Server to 1.25.0](https://github.com/zwave-js/zwave-js-server/releases/tag/1.25.0)
- [Bump Z-Wave JS to 10.5.4](https://github.com/zwave-js/node-zwave-js/releases/tag/v10.5.4)

## 0.1.74

- [Bump Z-Wave JS Server to 1.24.0](https://github.com/zwave-js/zwave-js-server/releases/tag/1.24.0)
- [Bump Z-Wave JS to 10.3.0](https://github.com/zwave-js/node-zwave-js/releases/tag/v10.3.0)

## 0.1.73

- [Bump Z-Wave JS Server to 1.23.1](https://github.com/zwave-js/zwave-js-server/releases/tag/1.23.1)
- [Bump Z-Wave JS to 10.2.0](https://github.com/zwave-js/node-zwave-js/releases/tag/v10.2.0)
- Bump Z-Wave JS to test build to try to address memory leak
- Revert to default base image

## 0.1.72

- Use same base image as community add-on zwave-js-ui

## 0.1.71

- [Bump Z-Wave JS to 10.1.0](https://github.com/zwave-js/node-zwave-js/releases/tag/v10.1.0)

## 0.1.70

- [Bump Z-Wave JS to 10.0.4](https://github.com/zwave-js/node-zwave-js/releases/tag/v10.0.4)

## 0.1.69

- Use edge version of NodeJS (16.17.0)
- Bump Alpine to 3.16

## 0.1.68

- [Bump Z-Wave JS to 10.0.3](https://github.com/zwave-js/node-zwave-js/releases/tag/v10.0.3)

## 0.1.67

- [Bump Z-Wave JS to 10.0.2](https://github.com/zwave-js/node-zwave-js/releases/tag/v10.0.2)

## 0.1.66

- [Bump Z-Wave JS Server to 1.22.1](https://github.com/zwave-js/zwave-js-server/releases/tag/1.22.1)
- [Bump Z-Wave JS to 10.0.1](https://github.com/zwave-js/node-zwave-js/releases/tag/v10.0.1)

## 0.1.65

- [Bump Z-Wave JS Server to 1.21.0](https://github.com/zwave-js/zwave-js-server/releases/tag/1.21.0)
- [Bump Z-Wave JS to 9.6.2](https://github.com/zwave-js/node-zwave-js/releases/tag/v9.6.2)

## 0.1.64

- Fix finish script for S6 V3

## 0.1.63

- [Bump Z-Wave JS Server to 1.20.0](https://github.com/zwave-js/zwave-js-server/releases/tag/1.20.0)

## 0.1.62

- [Bump Z-Wave JS Server to 1.19.0](https://github.com/zwave-js/zwave-js-server/releases/tag/1.19.0)

## 0.1.61

- [Bump Z-Wave JS to 9.4.0](https://github.com/zwave-js/node-zwave-js/releases/tag/v9.4.0)
- [Bump Z-Wave JS Server to 1.18.0](https://github.com/zwave-js/zwave-js-server/releases/tag/1.18.0)

## 0.1.60

- Fix permissions issue with startup scripts

## 0.1.59

- [Bump Z-Wave JS to 9.3.0](https://github.com/zwave-js/node-zwave-js/releases/tag/v9.3.0)
- [Bump Z-Wave JS Server to 1.17.0](https://github.com/zwave-js/zwave-js-server/releases/tag/1.17.0)

## 0.1.58

- [Bump Z-Wave JS to 9.0.7](https://github.com/zwave-js/node-zwave-js/releases/tag/v9.0.7)
- [Bump Z-Wave JS Server to 1.16.1](https://github.com/zwave-js/zwave-js-server/releases/tag/1.16.1)

## 0.1.57

- [Bump Z-Wave JS to 9.0.4](https://github.com/zwave-js/node-zwave-js/releases/tag/v9.0.4)

## 0.1.56

- [Bump Z-Wave JS to 9.0.2](https://github.com/zwave-js/node-zwave-js/releases/tag/v9.0.2)
- [Bump Z-Wave JS Server to 1.16.0](https://github.com/zwave-js/zwave-js-server/releases/tag/1.16.0)

## 0.1.55

- [Bump Z-Wave JS to 8.11.9](https://github.com/zwave-js/node-zwave-js/releases/tag/v8.11.9)

## 0.1.54

- [Bump Z-Wave JS to 8.11.6](https://github.com/zwave-js/node-zwave-js/releases/tag/v8.11.6)
- [Bump Z-Wave JS Server to 1.15.0](https://github.com/zwave-js/zwave-js-server/releases/tag/1.15.0)

## 0.1.53

- [Bump Z-Wave JS to 8.11.5](https://github.com/zwave-js/node-zwave-js/releases/tag/v8.11.5)

## 0.1.52

- [Bump Z-Wave JS to 8.10.2](https://github.com/zwave-js/node-zwave-js/releases/tag/v8.10.2)
- [Bump Z-Wave JS Server to 1.14.1](https://github.com/zwave-js/zwave-js-server/releases/tag/1.14.1)

## 0.1.51

- [Bump Z-Wave JS to 8.9.2](https://github.com/zwave-js/node-zwave-js/releases/tag/v8.9.2)
- [Bump Z-Wave JS Server to 1.14.0](https://github.com/zwave-js/zwave-js-server/releases/tag/1.14.0)

## 0.1.50

- [Bump Z-Wave JS to 8.8.3](https://github.com/zwave-js/node-zwave-js/releases/tag/v8.8.3)

## 0.1.49

- [Bump Z-Wave JS to 8.7.7](https://github.com/zwave-js/node-zwave-js/releases/tag/v8.7.7)
- [Bump Z-Wave JS Server to 1.12.0](https://github.com/zwave-js/zwave-js-server/releases/tag/1.12.0)

## 0.1.48

- [Bump Z-Wave JS to 8.7.6](https://github.com/zwave-js/node-zwave-js/releases/tag/v8.7.6)
- [Bump Z-Wave JS Server to 1.11.0](https://github.com/zwave-js/zwave-js-server/releases/tag/1.11.0)

## 0.1.47

- Disable soft-reset if VM is detected

## 0.1.46

- [Bump Z-Wave JS to 8.7.5](https://github.com/zwave-js/node-zwave-js/releases/tag/v8.7.5)
- [Bump Z-Wave JS Server to 1.10.8](https://github.com/zwave-js/zwave-js-server/releases/tag/1.10.8)

## 0.1.45

- [Bump Z-Wave JS Server to 1.10.7](https://github.com/zwave-js/zwave-js-server/releases/tag/1.10.7)

## 0.1.44

- Fix casing issues with security keys
- Fix `emulate_hardware` configuration option

## 0.1.43

- [Bump Z-Wave JS Server to 1.10.6](https://github.com/zwave-js/zwave-js-server/releases/tag/1.10.6)

## 0.1.42

- Retain legacy network_key config option to stay backwards compatible.

## 0.1.41

- [Bump Z-Wave JS Server to 1.10.5](https://github.com/zwave-js/zwave-js-server/releases/tag/1.10.5)
- [Bump Z-Wave JS to 8.4.1](https://github.com/zwave-js/node-zwave-js/releases/tag/v8.4.1)
- Add support for S2 keys in the addon configuration (check the Security Keys section of the configuration docs for more details)

## 0.1.40

- [Bump Z-Wave JS to 8.3.0](https://github.com/zwave-js/node-zwave-js/releases/tag/v8.3.0)

## 0.1.39

- [Bump Z-Wave JS to 8.2.3](https://github.com/zwave-js/node-zwave-js/releases/tag/v8.2.3)

## 0.1.38

- [Bump Z-Wave JS Server to 1.10.3](https://github.com/zwave-js/zwave-js-server/releases/tag/1.10.3)
- [Bump Z-Wave JS to 8.2.1](https://github.com/zwave-js/node-zwave-js/releases/tag/v8.2.1)

## 0.1.37

- [Bump Z-Wave JS Server to 1.10.0](https://github.com/zwave-js/zwave-js-server/releases/tag/1.10.0)

## 0.1.36

- [Bump Z-Wave JS to 8.1.1](https://github.com/zwave-js/node-zwave-js/releases/tag/v8.1.1)

## 0.1.35

- [Bump Z-Wave JS Server to 1.9.3](https://github.com/zwave-js/zwave-js-server/releases/tag/1.9.3)
- [Bump Z-Wave JS to 8.0.8](https://github.com/zwave-js/node-zwave-js/releases/tag/v8.0.8)

## 0.1.34

- [Bump Z-Wave JS Server to 1.9.2](https://github.com/zwave-js/zwave-js-server/releases/tag/1.9.2)

## 0.1.33

- [Bump Z-Wave JS to 8.0.6](https://github.com/zwave-js/node-zwave-js/releases/tag/v8.0.6)

## 0.1.32

- [Bump Z-Wave JS to 8.0.5](https://github.com/zwave-js/node-zwave-js/releases/tag/v8.0.5)

## 0.1.31

- [Bump Z-Wave JS Server to 1.9.1](https://github.com/zwave-js/zwave-js-server/releases/tag/1.9.1)

## 0.1.30

- [Bump Z-Wave JS to 8.0.3](https://github.com/zwave-js/node-zwave-js/releases/tag/v8.0.3)
- [Bump Z-Wave JS Server to 1.9.0](https://github.com/zwave-js/zwave-js-server/releases/tag/1.9.0)

## 0.1.29

- [Bump Z-Wave JS to 7.12.0](https://github.com/zwave-js/node-zwave-js/releases/tag/v7.12.0)

## 0.1.28

- [Bump Z-Wave JS to 7.10.0](https://github.com/zwave-js/node-zwave-js/releases/tag/v7.10.0)
- [Bump Z-Wave JS Server to 1.8.0](https://github.com/zwave-js/zwave-js-server/releases/tag/1.8.0)

## 0.1.27

- [Bump Z-Wave JS to 7.9.0](https://github.com/zwave-js/node-zwave-js/releases/tag/v7.9.0)

## 0.1.26

- [Bump Z-Wave JS to 7.7.4](https://github.com/zwave-js/node-zwave-js/releases/tag/v7.7.4)

## 0.1.25

- [Bump Z-Wave JS to 7.7.3](https://github.com/zwave-js/node-zwave-js/releases/tag/v7.7.3)

## 0.1.24

- [Bump Z-Wave JS to 7.7.0](https://github.com/zwave-js/node-zwave-js/releases/tag/v7.7.0)
- Create persistent directory for device config files to allow for future config updating functionality through the Home Assistant UI.

## 0.1.23

- [Bump Z-Wave JS Server to 1.7.0](https://github.com/zwave-js/zwave-js-server/releases/tag/1.7.0)
- [Pin Z-Wave JS to 7.6.0](https://github.com/zwave-js/node-zwave-js/releases/tag/v7.6.0)

## 0.1.22

- [Bump Z-Wave JS Server to 1.6.0](https://github.com/zwave-js/zwave-js-server/releases/tag/1.6.0)
- [Pin Z-Wave JS to 7.5.2](https://github.com/zwave-js/node-zwave-js/releases/tag/v7.5.2)

## 0.1.21

- [Pin Z-Wave JS to 7.3.0](https://github.com/zwave-js/node-zwave-js/releases/tag/v7.3.0)

## 0.1.20

- [Bump Z-Wave JS Server to 1.5.0](https://github.com/zwave-js/zwave-js-server/releases/tag/1.5.0)
- [Pin Z-Wave JS to 7.2.4](https://github.com/zwave-js/node-zwave-js/releases/tag/v7.2.4)

## 0.1.19

- [Pin Z-Wave JS to 7.2.3](https://github.com/zwave-js/node-zwave-js/releases/tag/v7.2.3)
- Make log level a configuration option

## 0.1.18

- [Pin Z-Wave JS to 7.2.2](https://github.com/zwave-js/node-zwave-js/releases/tag/v7.2.2)

## 0.1.17

- [Bump Z-Wave JS Server to 1.4.0](https://github.com/zwave-js/zwave-js-server/releases/tag/1.4.0)
- [Pin Z-Wave JS to 7.1.1](https://github.com/zwave-js/node-zwave-js/releases/tag/v7.1.1)

## 0.1.16

- [Bump Z-Wave JS Server to 1.3.1](https://github.com/zwave-js/zwave-js-server/releases/tag/1.3.1)

## 0.1.15

- [Pin Z-Wave JS to version 7.0.1](https://github.com/zwave-js/node-zwave-js/releases/tag/v7.0.1)

## 0.1.14

- [Bump Z-Wave JS Server to 1.3.0](https://github.com/zwave-js/zwave-js-server/releases/tag/1.3.0)
- [Pin Z-Wave JS to version 7.0.0](https://github.com/zwave-js/node-zwave-js/releases/tag/v7.0.0)

## 0.1.13

- [Bump Z-Wave JS Server to 1.2.1](https://github.com/zwave-js/zwave-js-server/releases/tag/1.2.1)
- [Pin Z-Wave JS to version 6.6.3](https://github.com/zwave-js/node-zwave-js/releases/tag/v6.6.3)
- Unpin Z-Wave JS dependencies

## 0.1.12

- [Bump Z-Wave JS to 6.5.1](https://github.com/zwave-js/node-zwave-js/releases/tag/v6.5.1)
- Pin Z-Wave JS dependencies

## 0.1.11

- [Bump Z-Wave JS Server to 1.1.1](https://github.com/zwave-js/zwave-js-server/releases/tag/1.1.1)

## 0.1.10

- [Bump Z-Wave JS Server to 1.1.0](https://github.com/zwave-js/zwave-js-server/releases/tag/1.1.0) This is the same code as 2.0.0. Home Assistant 2021.2 rejects any ZJS Server version that is v2+

## 0.1.9

- Bump Z-Wave JS Server to 2.0.0

## 0.1.8

- [Bump Z-Wave JS Server to 1.0.0](https://github.com/zwave-js/zwave-js-server/releases/tag/1.0.0)
- [Pin Z-Wave JS to version 6.5.0](https://github.com/zwave-js/node-zwave-js/releases/tag/v6.5.0)

## 0.1.7

- [Bump Z-Wave JS Server to 1.0.0-beta.6](https://github.com/zwave-js/zwave-js-server/releases/tag/1.0.0-beta.6)

## 0.1.6

- [Update Z-Wave JS to version 6.2.0](https://github.com/zwave-js/node-zwave-js/releases/tag/v6.2.0)

## 0.1.5

- Update hardware configuration for Supervisor 2021.02.5
- [Upgrade Z-Wave JS Server to 1.0.0-beta.5](https://github.com/zwave-js/zwave-js-server/releases/tag/1.0.0-beta.5)
- [Pin Z-Wave JS to version 6.1.3](https://github.com/zwave-js/node-zwave-js/releases/tag/v6.1.3)

## 0.1.4

- [Bump Z-Wave JS Server to 1.0.0-beta.4](https://github.com/zwave-js/zwave-js-server/releases/tag/1.0.0-beta.4)

## 0.1.3

- [Bump Z-Wave JS Server to 1.0.0-beta.3](https://github.com/zwave-js/zwave-js-server/releases/tag/1.0.0-beta.3)

## 0.1.2

- [Bump Z-Wave JS Server to 1.0.0-beta.2](https://github.com/zwave-js/zwave-js-server/releases/tag/1.0.0-beta.2)

## 0.1.1

- [Bump Z-Wave JS Server to 1.0.0-beta.1](https://github.com/zwave-js/zwave-js-server/releases/tag/1.0.0-beta.1)

## 0.1.0

- Initial release
