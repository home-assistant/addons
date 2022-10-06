# Home Assistant Add-on: Matter Server

## Installation

Use the following steps to install this add-on.

1. Click the Home Assistant My button below to open the add-on page on your
   Home Assistant instance.

   [![Open this add-on in your Home Assistant instance.][addon-badge]][addon]

1. Click the "Install" button to install the add-on.

## How to use

Start the Matter Server add-on to make the WebSocket available to Home
Assistant Core. Install the custom_component from the [python-matter-server
repository][matter_server_repo].

## Configuration

Add-on configuration:

| Configuration      | Description                                                 |
|--------------------|-------------------------------------------------------------|
| chip_debug         | Start the Matter Controller with debug log level enabled.   |

## Support

Got questions?

You have several options to get them answered:

- The [Home Assistant Discord Chat Server][discord].
- The Home Assistant [Community Forum][forum].
- Join the [Reddit subreddit][reddit] in [/r/homeassistant][reddit]

In case you've found a bug, please [open an issue on our GitHub][issue].

[addon]: https://my.home-assistant.io/redirect/supervisor_addon/?addon=77f1785d_matter_server&repository_url=https%3A%2F%2Fgithub.com%2Fhome-assistant%2Faddons
[addon-badge]: https://my.home-assistant.io/badges/supervisor_addon.svg
[discord]: https://discord.gg/c5DvZ4e
[forum]: https://community.home-assistant.io
[reddit]: https://reddit.com/r/homeassistant
[issue]: https://github.com/home-assistant/addons/issues
[matter_server_repo]: https://github.com/home-assistant-libs/python-matter-server
