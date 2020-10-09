# Changelog

## 8.9.1

- Fix bluez package

## 8.9.0

- Update Home Assistant CLI to 4.4.1
- Add Bluetooth support

## 8.8.1

- Support new media folder

## 8.8.0

- Update Home Assistant CLI to 4.4.1
- Wrap system shutdown/reboot to supervisor

## 8.7.0

- Update Home Assistant CLI to 4.4.0
- Upgrade Alpine Linux to 3.12


## 8.6.0

- Add support for local TCP forwarding

## 8.5.4

- Update Home Assistant CLI to 4.3.0

## 8.5.3

- Update Home Assistant CLI to 4.2.0

## 8.5.2

- Update Home Assistant CLI to 4.1.0

## 8.5.1

- Show warning if SSH port is disabled

## 8.5.0

- Add support for PulseAudio with new Audio backend
- Migrate to s6-overlay

## 8.4.0

- Support to use only web terminal without SSH server

**ATTENTION:** If you want access with SSH, you need maybe add the Port setting option back.

## 8.3.0

- Update Home Assistant CLI to 4.0.1
- Add backward compatibility with the hassio command
- Update Web terminal to ttyd 1.6.0 with Libwebsockets 3.2.2
- Rename HASSIO_TOKEN to SUPERVISOR_TOKEN in shell profile

## 8.2.0

- Fix creation of new tmux terminal windows
- Add add-on icon
- Update welcome logo
- Fix SSH folder issue with authorized keys

## 8.1.0

- Fix for non existing .bash_profile startup error
- Add current, short, path to command line prompt

## 8.0.0

- Add support for a web-based terminal via Ingress
- Upgrade Alpine Linux to 3.11
- Improve Hass.io API token handling
- Persist .ssh folder across restarts
- Add helper symlink folders to user home folder

## 7.1.0

- Update Hass.io CLI to 3.1.1

## 7.0.0

- Added bash_profile as a persistent file

