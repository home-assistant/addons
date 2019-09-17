# Changelog

## 5.1

- Add cafile option in configuration
- Add require_certificate option in configuration

## 5.0

- Update mosquitto 1.6.3 / Alpine 3.10
- Migrate to `mosquitto-auth-plug` from pvizeli
- Use auth cache for faster reauthentication

## 4.3

- Fix password generator with new images

## 4.2

- Enable quiet logging for http auth plugin

## 4.1

- Update mosquitto 1.5.6

## 4.0

- Use Alpine 3.7 because libwebsocket 3.0.0 is broken on Alpine 3.8

## 3.0

- Use auto setup (discovery) on Home Assistant
- Publish his service to Hass.io
- Attach to Home Assistant user system
- Set anonymous default to false

## 2.0

- Update mosquitto to 1.4.15
- New options to allow clients to connect through websockets
