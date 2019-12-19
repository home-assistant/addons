# Hass.io Addons: The official core repository

[![Build Status](https://dev.azure.com/home-assistant/Hass.io/_apis/build/status/addons?branchName=master)](https://dev.azure.com/home-assistant/Hass.io/_build/latest?definitionId=7&branchName=master)

Add-ons for the Hass.io ecosystem, allow you to extend the functionality
around your Home Assistant setup. These add-on can consist of an application
that Home Assistant can integrate with (e.g., a MQTT broker or database server)
or allow access to your Home Assistant configuration (e.g., via Samba or using
the Configurator).

Add-ons can be installed and configured via the Home Assistant frontend on
systems that have installed Hass.io.

## Add-ons provided by this repository

- **[Almond](/almond/README.md)**

    Almond For Home Servers.

- **[CEC Scanner](/cec_scan/README.md)**

    Scan & discover HDMI CEC devices and their addresses.

- **[Check Home Assistant configuration](/check_config/README.md)**

    Check your current configuration against any Home Assistant version.

- **[Configurator](/configurator/README.md)**

    Browser-based configuration file editor for Home Assistant.

- **[deCONZ](/deconz/README.md)**

    Control a ZigBee network using ConBee or RaspBee hardware by Dresden Elektronik.

- **[DHCP server](/dhcp_server/README.md)**

    A simple DHCP server.

- **[Dnsmasq](/dnsmasq/README.md)**

    A simple DNS server.

- **[Duck DNS](/duckdns/README.md)**

    Automatically update your Duck DNS IP address with integrated HTTPS support via Let's Encrypt.

- **[Git pull](/git_pull/README.md)**

    Load and update configuration files for Home Assistant from a Git repository.

- **[Google Assistant SDK](/google_assistant/README.md)**

    A virtual personal assistant developed by Google.

- **[Hey Ada!](/ada/README.md)**

    Home Assistant featured voice assistant.

- **[HomeMatic](/homematic/README.md)**

    HomeMatic central based on OCCU.

- **[Let's Encrypt](/duckdns/README.md)**

    Manage an create certificates from Let's Encrypt.

- **[MariaDB](/mariadb/README.md)**

    MariaDB database for Home Assistant.

- **[Mosquitto broker](/mosquitto/README.md)**

    An Open Source MQTT broker.

- **[NGINX Home Assistant SSL proxy](/nginx_proxy/README.md)**

    Sets up an SSL proxy with NGINX and redirects traffic from port 80 to 443.

- **[RPC Shutdown](/rpc_shutdown/README.md)**

    Shutdown Windows machines remotely.

- **[Samba share](/samba/README.md)**

    Expose Hass.io folders with SMB/CIFS.

- **[Snips.AI](/snips/README.md)**

    Local voice control platform.

- **[SSH server](/ssh/README.md)**

    Allow logging in remotely to Hass.io using SSH.

- **[TellStick](/tellstick/README.md)**

    TellStick and TellStick Duo service.

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
[issue]: https://github.com/home-assistant/hassio-addons/issues
[reddit]: https://reddit.com/r/homeassistant
[dev-docs]: https://developers.home-assistant.io/docs/en/hassio_addon_index.html
