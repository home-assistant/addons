# Home Assistant Add-ons: The official repository

Add-ons for Home Assistant, allow you to extend the functionality
around your Home Assistant setup. These add-ons can consist of an application
that Home Assistant can integrate with (e.g., a MQTT broker or database server)
or allow access to your Home Assistant configuration (e.g., via Samba or using
the Configurator).

Add-ons can be installed and configured via the Home Assistant frontend on
systems that have installed Home Assistant.

## Add-ons provided by this repository

- **[Almond](/almond/README.md)**

    Almond For Home Servers.

- **[CEC Scanner](/cec_scan/README.md)**

    Scan & discover HDMI CEC devices and their addresses.

- **[deCONZ](/deconz/README.md)**

    Control a Zigbee network using ConBee or RaspBee hardware by Dresden Elektronik.

- **[DHCP server](/dhcp_server/README.md)**

    A simple DHCP server.

- **[Dnsmasq](/dnsmasq/README.md)**

    A simple DNS server.

- **[Duck DNS](/duckdns/README.md)**

    Automatically update your Duck DNS IP address with integrated HTTPS support via Let's Encrypt.

- **[File editor](/configurator/README.md)**

    Simple browser-based file editor for Home Assistant.

- **[Git pull](/git_pull/README.md)**

    Load and update configuration files for Home Assistant from a Git repository.

- **[Google Assistant SDK](/google_assistant/README.md)**

    A virtual personal assistant developed by Google.

- **[Hey Ada!](/ada/README.md)**

    Voice assistant powered by Home Assistant.

- **[Let's Encrypt](/letsencrypt/README.md)**

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

    Expose Home Assistant folders with SMB/CIFS.

- **[SSH server](/ssh/README.md)**

    Allow logging in remotely to Home Assistant using SSH.

- **[TellStick](/tellstick/README.md)**

    TellStick and TellStick Duo service.

- **[Z-Wave JS](/zwave_js/README.md)**

    Allow Home Assistant to talk to a Z-Wave Network via a USB Controller.

### Deprecated Add-ons

- **[HomeMatic](/homematic/README.md)**

    HomeMatic central based on OCCU.

    Deprecated in favor of the much more advanced third-party [RaspberryMatic CCU](https://github.com/jens-maus/RaspberryMatic/tree/master/home-assistant-addon).

- **[OpenZWave](/zwave/README.md)**

    Allow Home Assistant to talk to a Z-Wave Network via a USB Controller.

    Deprecated in favor of [Z-Wave JS](/zwave_js/README.md)

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
[dev-docs]: https://developers.home-assistant.io/docs/add-ons
