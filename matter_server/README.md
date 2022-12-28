# Home Assistant Add-on: Matter Server

![Supports aarch64 Architecture][aarch64-shield]
![Supports amd64 Architecture][amd64-shield]

## About

Matter Python WebSocket Server for Home Assistant Core. Matter (formerly
known as Connected Home over IP or CHIP) is an IPv6 based smart home
standard. This add-on provides a Matter Controller which allows you to
commission and control of Matter devices. The matching Home Assistant Core
integration communicates via WebSocket with this server.

[aarch64-shield]: https://img.shields.io/badge/aarch64-yes-green.svg
[amd64-shield]: https://img.shields.io/badge/amd64-yes-green.svg

## Matter Server Update Procedure

When updating the server library in the add-on follow these steps:

1. Update the `MATTER_SERVER_VERSION` argument in `build.yaml`.
2. Check if the chip SDK version has changed in the server library.
3. If the chip SDK version has changed, set the `homeassistant` key in `config.yaml` to the minimum version of Home Assistant Core required to install or update the add-on. Home Assistant Core needs to have the exact same version of the chip SDK as the server.
4. Update the add-on version in `config.yaml`.
5. Update the changelog in `CHANGELOG.md`. Include a markdown link to the GitHub release of the server in the changelog.
