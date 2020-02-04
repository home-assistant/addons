# Home Assistant Add-on: Check Home Assistant configuration

Check your current configuration against any Home Assistant version.

![Supports aarch64 Architecture][aarch64-shield] ![Supports amd64 Architecture][amd64-shield] ![Supports armhf Architecture][armhf-shield] ![Supports armv7 Architecture][armv7-shield] ![Supports i386 Architecture][i386-shield]

## About

You can use this add-on to check whether your configuration files are valid against the
new version of Home Assistant before you actually update your Home Assistant
installation. This add-on will help you avoid errors due to breaking changes,
resulting in a smooth update.

## Installation

Follow these steps to get the add-on installed on your system:

1. Navigate in your Home Assistant frontend to **Hass.io** -> **Add-on Store**.
2. Find the "Check Home Assistant configuration" add-on and click it.
3. Click on the "INSTALL" button.

## How to use

In the configuration section, set the version you want to check your configuration
against. In case you'd like to check your configuration against the latest version of
Home Assistant, leave it set to `latest`, which is already there as the default.

1. Start the add-on.
2. Have some patience and wait a couple of minutes.
3. Check the add-on log output to see the result.

If the log ends with `Configuration check finished - no error found! :)`,
it means the check against your configuration passes on the specified
Home Assistant version.

## Configuration

Add-on configuration:

```json
{
  "version": "latest"
}
```

### Option: `version` (required)

The version of Home Assistant that want to check your configuration against.

Setting this option to `latest` will result in checking your configuration
against the latest stable release of Home Assistant.

## Known issues and limitations

- Currently, this add-on only supports checking against Home Assistant >= 0.94
  or less 0.91.

## Support

Got questions?

You have several options to get them answered:

- The [Home Assistant Discord Chat Server][discord].
- The Home Assistant [Community Forum][forum].
- Join the [Reddit subreddit][reddit] in [/r/homeassistant][reddit]

In case you've found a bug, please [open an issue on our GitHub][issue].

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
