# Changelog

## 6.3.0

- Update mosquitto to 2.0.17

## 6.2.1

- Add explicit dependencies for dynamic security plugin and asynchronous name resolver 

## 6.2.0

- Update mosquitto to 2.0.15
- Update libwebsockets to 4.3.2 (fixes Unable to create websockets listener)

## 6.1.3

- Change timestamp format in logs

## 6.1.2

- Add debug option to help with issues

## 6.1.1

- Don't purge openssl in cleanup

## 6.1.0

- Update mosquitto to 2.0.11
- Remove `mosquitto-auth-plug` and replace with `mosquitto-go-auth` 1.8.2
- Change base image from Alpine to Debian (required for `mosquitto-go-auth`)

Note: Mosquitto 2.0.0 did contain some breaking changes. We don't anticipate
most users to be affected by them but if you have a heavily customized mosquitto
config we would advise reviewing [their changelog](https://mosquitto.org/ChangeLog.txt). 

## 6.0.2

- Mention homeassistant and addon users in ACL doc

## 6.0.1

- Fix loading custom mosquitto configuration

## 6.0.0

- Support for anonymous logins has been removed
- Replaced Home Assistant authentication handling
- Merged local account handling with authentication plugin
- Add watchdog endpoint for health monitoring
- Updated mosquitto to 1.6.12
- Updated mosquitto auth plugin to 0.1.5
- Migrate add-on layout to S6 Overlay
- Migrate all script to use Bashio
- Update base image to Alpine Linux 3.13
- Add port descriptions

## 5.1.1

- Update options schema for passwords

## 5.1.0

- Add cafile option in configuration
- Add require_certificate option in configuration

## 5.0.0

- Update mosquitto 1.6.3 / Alpine 3.10
- Migrate to `mosquitto-auth-plug` from pvizeli
- Use auth cache for faster reauthentication

## 4.3.0

- Fix password generator with new images

## 4.2.0

- Enable quiet logging for http auth plugin

## 4.1.0

- Update mosquitto 1.5.6

## 4.0.0

- Use Alpine 3.7 because libwebsocket 3.0.0 is broken on Alpine 3.8
