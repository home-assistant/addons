# Changelog

#### WARNING: This add-on is considered to be obsolete/retired in favor of the much more advanced third-party [RaspberryMatic CCU](https://github.com/jens-maus/RaspberryMatic/tree/master/home-assistant-addon) add-on for running a HomeMatic/homematicIP smart home central within HomeAssistant. If you want to migrate to the new add-on, please make sure to update to the latest version of this old "HomeMatic CCU" add-on first and then use the WebUI-based backup routines to export a `*.sbk` config backup file which you can then restore in the new "RaspberryMatic CCU" add-on afterwards (cf. [RaspberryMatic Documentation](https://github.com/jens-maus/RaspberryMatic/wiki/Installation-HomeAssistant))

## 99.0.5

- integrated yet another backup script fix to avoid errors on backup creation.

## 99.0.4

- integrated another backup script fix to avoid errors on backup creation.

## 99.0.3

- integrated backup script fix to generate .sbk backups more
  compatible to a standard CCU.

## 99.0.2

- disabled hmip rf-firmware update to prevent accidently performed
  firmware downgrade (not required anymore for obsolete addon anyway)
- added missing gnu.io.rxtx.SerialPorts java option to get hmipserver
  running with raw-uart device.

## 99.0.1

- minor bugfix to get webui backup routines running.

## 99.0.0

- added a notification to the main add-on README that this add-on
  is now considered obsolete/retired in favor of using the
  "RaspberryMatic CCU" HomeAssistant add-on instead.
- implemented a config backup routine which will allow to export
  the current HomeMatic configuration in a somewhat compatible
  file format (.sbk) to be able to directly import it into a
  real CCU or the successor "RaspberryMatic" add-on.
- modified config.yaml to allow to specify arbitrary devices and
  not just tty devices. This should allow to specify the new
  raw-uart device which will be required with upcoming HAos updates
  supporting dualcopro mode for HmIP-RFUSB.

## 11.3.0

- Update OCCU to 3.59.6

## 11.2.2

- Revert restart nginx service on error

## 11.2.1

- Restart nginx service on error

## 11.2.0

- Update OCCU to 3.55.10

## 11.1.0

- Migrate OCCU back to EQ3
- Use Home helper again
- Update hardware configuration for Supervisor 2021.02.5

## 11.0.6

- Persist groups

## 11.0.5

- Skip HmIP firmware update for udev path
- Persist certificate

## 11.0.4

- Fix template for hmip

## 11.0.3

- Fix Ingress path

## 11.0.2

- Fix issue with library
- Take container down on ReGaHss error

## 11.0.1

- Small cleanup with s6-overlay

## 11.0.0

- Migrate to s6-overlay & tempio
- Update OCCU to 3.55.5-1

## 10.3.0

- Flush ReGaHss config on shutdown
- Add ReGaHss reset option

## 10.2.0

- Update Bashio to fix the wait function
- Extend the log output

## 10.1.0

- Fix issue with SSL

## 10.0.0

- Add Ingress support
- Disable external ports per default
- Fix wrong version number
- Speedup start without sleeps
