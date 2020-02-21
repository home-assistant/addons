# Changelog

## 10.3

- Flush ReGaHss config on shutdown
- Add ReGaHss reset option

## 10.2

- Update Bashio to fix the wait function
- Extend the log output

## 10.1

- Fix issue with SSL

## 10.0

- Add Ingress support
- Disable external ports per default
- Fix wrong version number
- Speedup start without sleeps

## 9.9

- Update glibc for armv7

## 9.8

- Update OCCU to 3.51.6-1

## 9.7

- Fix glibc error on i386/amd64

## 9.6

- Update OCCU to 3.49.17-4
- Use new gcc8 binary for i386
- Change ReGaHass to normal version

## 9.5

- Fix ReGaHss binary

## 9.4

- Update OCCU to 3.49.17-2
- Use new gcc8 binary for armhf
- Don't use ReGaHss-beta

## 9.3

- Update from bash to bashio
- Use debian as base image
- Fix config for group settings

## 9.2

- Update OCCU to 3.47.22-3

## 9.1

- Optimize InterfaceList handling
- Make userprofiles static

## 9.0

- Add Regahss (WebUI) support (experimentel)
- Update OCCU to 3.47.18-1

## 8.3

- Update OCCU to 3.47.10
- Add Port descriptions

## 8.2

- Update OCCU to 3.45.7

## 8.1

- Update OCCU to 3.43.15
- Migrate to new arch layering
- Better handling for errors with Firmware updates

## 8.0

- Update OCCU to 3.41.11
- Fix write error when starting OCCU / HmIP
- Redirect HMIPServer log to console

## 7.0

- Update OCCU to 3.41.7

## 6.0

- Allow customer firmware updates inside `/share`
- Update Hardware on startup
- Limit HmIP server to 64mb memory
- Set `rf_enable` default to `false`

## 5.0

- Save hmip_address.conf persistent

## 4.0

- New ubuntu base images
- Support firmware update of HM-MOD-RPI-PCB, HmIP-RFUSB
- Add HmIP support with HmIP-RFUSB

## 3.0

- Add periodically time sync

## 2.0

- Fix wrong Timezone
- Update OCCU to 3.37.8

## 1.0

- Change version format to other core add-ons
- Update OCCU to 2.35.16
- Disable AppArmor to work on system like HassOS

## 2.31.25-p2

- Bugfix with reset value on GPIO

## 2.31.25-p1

- Add `reset` options for RF modules

## 2.31.25-p0

- Update OCCU to 2.31.25

## 2.31.23-p0

- Update OCCU to 2.31.23

## 2.29.22-1-p1

- Fix bug in script
- Add wired port into config

## 2.29.22-1-p1

- Change config logic
- Add support for wired

## 2.29.22-1-p0

- Initial
