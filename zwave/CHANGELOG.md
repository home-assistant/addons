# Changelog

## 0.5.4

- Fix build issues with 32bit CPU

## 0.5.3

-  Update Openzwave to 7eaae21

## 0.5.2

- Fix startup failure due to stray OZW Daemon status retained in MQTT
- Propagate shutdown OZW Daemon status to upstream MQTT on shutdown
- Update OpenZWave to 6cf3729

## 0.5.1

- Roll-back alpine to 3.11 and qt 5.12
- Roll-back OpenZWave to 6c2ca613

## 0.5.0

- Update OpenZWave to 5d3978d5
- Update ozw-admin to da04ebfb
- Update qt-openzwave to 3ad9138f
- Update alpine to 3.12

## 0.4.4

- Update OpenZWave to a35732f
- Update ozw-admin to 278427b

## 0.4.3

- Update OpenZWave to 6cec95b
- Update ozw-admin to 167180c

## 0.4.2

- Improve error message when using documented network_key

## 0.4.1

- Fix optional instance parameter

## 0.4.0

- Add OZW instance ID configuration option
- Fix persistent storage of OpenZWave
- Fix permissions on discovery script
- Fix OZW database location
- Improve build speed by using all available cores
- Add built-in ozw-admin
- Add VNC access to add-on to access ozw-admin
- Add Ingress support to add-on to access ozw-admin
- Documentation improvements
- Update OpenZWave (and database) to d2de699
- Update ozwdaemon to 337e488
- Add logo and icon
- Detect use of example network key from documentation

## 0.3.0

- Add port to allow ozw-admin to connect
- Enable discovery again
- Set network key default to empty

## 0.2.1

- Disable discovery for 0.110.0

## 0.2.0

- Update OZW / QTOZW
- Rename `zwave_mqtt` to `ozw`

## 0.1.1

- Fix i386 build

## 0.1.0

- Inital release
