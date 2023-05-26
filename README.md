# Home Assistant Add-ons: Not so official repository

Add-ons for Home Assistant allow you to extend the functionality
around your Home Assistant setup. These add-ons can consist of an application
that Home Assistant can integrate with (e.g., a [MQTT broker](/mosquitto/README.md) or [database server](/mariadb/README.md))
or allow access to your Home Assistant configuration (e.g., via [Samba](/samba/README.md) or using
the [File Editor](/configurator/README.md)).

Add-ons can be installed and configured via the Home Assistant frontend on
systems that have installed Home Assistant.

## Add-ons provided by this repository

- **[deCONZ](/deconz/README.md)**

    Control a Zigbee network using ConBee or RaspBee hardware by Dresden Elektronik.

- **[Git pull](/git_pull/README.md)**

    Load and update configuration files for Home Assistant from a Git repository.

- **[Samba share](/samba/README.md)**

    Share your configuration over the network using Windows file sharing.

## Support

Got questions?

You have several options to get them answered:

- The [Home Assistant Discord Chat Server][discord].
- The Home Assistant [Community Forum][forum].
- Join the [Reddit subreddit][reddit] in [/r/homeassistant][reddit]

In case you've found a bug, please [open an issue on our GitHub][issue].

## Developing your own add-ons

In case you are interested in developing your own add-on, this
repository can be a great source of inspiration. For more information
about developing an add-on, please see our
[documentation for developers][dev-docs].

[discord]: https://discord.gg/c5DvZ4e
[forum]: https://community.home-assistant.io
[i386-shield]: https://img.shields.io/badge/i386-no-red.svg
[issue]: https://github.com/home-assistant/addons/issues
[reddit]: https://reddit.com/r/homeassistant
[dev-docs]: https://developers.home-assistant.io/docs/add-ons/
