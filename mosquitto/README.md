# Hass.io Core Add-on: Mosquitto broker

Check your current configuration against any Home Assistant version.

![Supports aarch64 Architecture][aarch64-shield] ![Supports amd64 Architecture][amd64-shield] ![Supports armhf Architecture][armhf-shield] ![Supports armv7 Architecture][armv7-shield] ![Supports i386 Architecture][i386-shield]

## About

You can use this add-on to to install Eclipse Mosquitto which is an open source (EPL/EDL licensed) message broker that implements the MQTT protocol. Mosquitto is lightweight and is suitable for use on all devices from low power single board computers to full servers.

## Installation

The installation of this add-on is straightforward and easy to do.

1. Navigate in your Home Assistant frontend to **Hass.io** -> **Add-on Store**.
2. Find the "Mosquitto broker" add-on and click it.
3. Click on the "INSTALL" button.

## How to use

The add-on has a couple of options available. For more detailed instructions see [mosquitto]. The basic thing to get the add-on running would be:

1. Start the add-on.
2. Have some patience and wait a couple of minutes.
3. Check the add-on log output to see the result.

## Configuration

Add-on configuration:

```json
{
  "logins": [],
  "anonymous": false,
  "customize": {
    "active": false,
    "folder": "mosquitto"
  },
  "certfile": "fullchain.pem",
  "keyfile": "privkey.pem",
  "require_certificate": false
}
```

### Option: `logins`

A list of local users that will be created with username and password. You don’t need do this because you can use Home Assistant users too without any configuration.

### Option: `anonymous`

Allow anonymous connections. If logins is set, the anonymous user can only read data.

### Option: `customize`

This option allows you to provide additional configuration files as needed.

#### Option: `customize` -> `active`

If set to true additional configuration files will be read, see next option.

#### Option: `customize` -> `folder`

The folder to read the  additional configuration files (*.conf) from.

### Option: `certfile`

File containing certificate including its chain.

### Option: `keyfile`

File containing the private key.

### Option: `require_certificate`

If set to true encryption will be enabled using the cert- and keyfile options.

## Known issues and limitations

## Support

Got questions?

You have several options to get them answered:

- The [Home Assistant Discord Chat Server][discord].
- The Home Assistant [Community Forum][forum].
- Join the [Reddit subreddit][reddit] in [/r/homeassistant][reddit]

In case you've found an bug, please [open an issue on our GitHub][issue].

[aarch64-shield]: https://img.shields.io/badge/aarch64-yes-green.svg
[amd64-shield]: https://img.shields.io/badge/amd64-yes-green.svg
[armhf-shield]: https://img.shields.io/badge/armhf-yes-green.svg
[armv7-shield]: https://img.shields.io/badge/armv7-yes-green.svg
[discord]: https://discord.gg/c5DvZ4e
[forum]: https://community.home-assistant.io
[i386-shield]: https://img.shields.io/badge/i386-yes-green.svg
[issue]: https://github.com/home-assistant/hassio-addons/issues
[reddit]: https://reddit.com/r/homeassistant
[repository]: https://github.com/hassio-addons/repository
[mosquitto]: https://www.home-assistant.io/addons/mosquitto/