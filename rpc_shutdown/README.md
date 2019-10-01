# Hass.io Core Add-on: RPC Shutdown

Simple way for remote windows shutdown.

![Supports aarch64 Architecture][aarch64-shield] ![Supports amd64 Architecture][amd64-shield] ![Supports armhf Architecture][armhf-shield] ![Supports armv7 Architecture][armv7-shield] ![Supports i386 Architecture][i386-shield]

## About

Allows you to shut down and Windows Computer with a service call from Home Assistant.

## Installation

The installation of this add-on is straightforward and easy to do.

1. Navigate in your Home Assistant frontend to **Hass.io** -> **Add-on Store**.
2. Find the "RPC Shutdown" add-on and click it.
3. Click on the "INSTALL" button.

## How to use

In the configuration section define alias,address and credentials and save the configuration.

1. Start the add-on.
2. Have some patience and wait a couple of minutes.
3. Check the add-on log output to see the result.

## Configuration

Add-on configuration:

```json
{
  "computers": [
    {
      "alias": "test-pc-1",
      "address": "192.168.0.1",
      "credentials": "user%password"
    },
    {
      "alias": "test-pc-2",
      "address": "192.168.0.2",
      "credentials": "user%password"
    }
  ]
}
```

## Home Assistant Configuration

```json
service: hassio.addon_stdin 
data: addon: core_rpc_shutdown 
input: test-pc
```

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
