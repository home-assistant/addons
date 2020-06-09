# Home Assistant Add-on: OpenZwave

## Installation

Follow these steps to get the add-on installed on your system:

1. Navigate in your Home Assistant frontend to **Supervisor** -> **Add-on Store**.
2. Find the "OpenZwave" add-on and click it.
3. Click on the "INSTALL" button.

## How to use

## Configuration

Add-on configuration:

```yaml
device: /dev/ttyUSB0
network_key: 
instance: 1
```

### Option `device`


### Option `network_key`


### Option `instance`

Zwave instance number as reported to MQTT.  This corresponds with the
`instance_id` attribute of `ozw` services in Home Assistant.


## Known issues and limitations

- You hardware need to be compatible with OpenZwave library

## Support

Got questions?

You have several options to get them answered:

- The [Home Assistant Discord Chat Server][discord].
- The Home Assistant [Community Forum][forum].
- Join the [Reddit subreddit][reddit] in [/r/homeassistant][reddit]

In case you've found a bug, please [open an issue on our GitHub][issue].



[discord]: https://discord.gg/c5DvZ4e
[forum]: https://community.home-assistant.io
[issue]: https://github.com/home-assistant/hassio-addons/issues
[reddit]: https://reddit.com/r/homeassistant
