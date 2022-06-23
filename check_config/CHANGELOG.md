# Changelog

## 3.11.0

This add-on is deprecated because it is no longer needed. Home Assistant now always starts after an update even if your config is invalid. You should do the following after an update to check for issues:

1. Check persistent notifications. If an integration could not be loaded because its config is invalid a notification will tell you.
2. Check logs. If an integration could be loaded but the config you are using is deprecated a message will tell you what needs to change and by when.
3. Follow the red banner. In rare cases HA will start in safe mode. In those cases you should follow the instructions in the red banner at the top of the UI.

## 3.10.2

- Fix check-config finish script

## 3.10.1

- Update base image to 2022.05.0

## 3.10.0

- Update base image to 2022.02.0

## 3.9.0

- Update base image to 2021.09.0
- Change default version from "latest" to "stable"
- Remove write access to /media

## 3.8.0

- Update base image to 2021.07.0
- Allow using `stable`, `beta` and `dev` as target versions
- Add translation file for English

## 3.7.1

- Update base image to 2021.04.3

## 3.7.0

- Update base image to 2021.04.2
- Suppress PIP install output, unless an error occurs
- Remove udev usage, replaced by uart & usb flag
- Fix S6 supervisor not listening message

## 3.6.0

- Change to rsync for copy
- Ignore HA db files

## 3.5.0

- Update base image to version 8.4.0
- Add media folder

## 3.4.0

- Update base image to version 8.1.0

## 3.3.0

- Update base image to version 7.2.0
- Add access to `share` folder for when using `whitelist_external_dirs`
- Fixes `fatal: unable to control: supervisor not listening`
- Show only top of the error log in add-on output
- Write full check config output to `/share/check_config.txt`
- Ensure service script does not crash when check config fails
- Hide pip version warning to avoid confusion

## 3.2.0

- Update base image to version 7.1.0
- Migrate to S6-overlay

## 3.1.0

- Moved the 'reassurance' log message "Don't worry, this temporary installation is not overwriting your current one." to earlier in the process.

## 3.0.0

- Use Home Assistant base image as base for this Add-on
- Disable external UDEV

## 2.2.0

- Update python/alpine to HA 0.96

## 2.1.0

- Adds additional information in log output to avoid confusion

## 2.0.0

- Migrated add-on onto Bashio
- Improved add-on log output
- Added documentation to add-on itself
- Added support for Home Assistant wheels repository
