# Home Assistant Add-on: OpenThread Border Router

## Installation

Follow these steps to get the add-on installed on your system:

1. Navigate in your Home Assistant frontend to **Settings** -> **Add-ons, Backup & Supervisor** -> **Add-on Store**.
2. Click on the top right menu and "Repository"
3. Add "https://github.com/home-assistant/addons" to add the "Home Assistant Add-on Repository for Development" repository.
4. Find the "OpenThread Border Router" add-on and click it.
5. Click on the "INSTALL" button.

## How to use

You will need a 802.15.4 capable radio supported by OpenThread. Home Assistant
Yellow as well as Home Assistant SkyConnect are both capable to run OpenThread.
This add-on automatically installs the necessary firmware on these systems.

If you are using Home Assistant Yellow, choose `/dev/ttyAMA1` as device.

### Alternative radios

The website [openthread.io maintains a list of supported platforms][openthread-platforms]
lists other Thread capable radios. A well documented Radio for development is the
Nordic Semiconductor [nRF52840 Dongle][nordic-nrf52840-dongle]. The Dongle needs
a recent version of the OpenThread OCP firmare.
[This article][nordic-nrf52840-dongle-install] outlines the steps to install the
RCP firmware for the nRF52840 Dongle.

Once the firmware is loaded follow the following steps:

1. Select the correct `device` in the add-on configuration tab and press `Save`.
2. Start the add-on.

### OpenThread Border Router

This add-on makes your Home Assistant installation an OpenThread Border Router
(OTBR). The border router can be used to comission Matter devices which connect
through Thread. Home Assistant Core will automatically detect this add-on and
create a new integration named "Open Thread Border Router". With Home Assistant
Core 2023.3 and newer the OTBR will get configured automatically. The Thread
integration allows to inspect the network configuration.

### Web interface (advanced)

There is also a web interface provided by the OTBR. However, the web
interface has caveats (e.g. forming a network does not generate an off-mesh
routable IPv6 prefix which causes changing IPv6 addressing on first add-on
restart). It is still possible to enable the web interface for debugging
purpose. Make sure to expose both the Web UI port and REST API port (the
latter needs to be on port 8081) on the host interface. To do so, click on
"Show disabled ports" and enter a port (e.g. 8080) in the OpenThread Web UI
and 8081 in the OpenThread REST API port field).

## Configuration

Add-on configuration:

| Configuration      | Description                                            |
|--------------------|--------------------------------------------------------|
| device (mandatory) | Serial port where the OpenThread RCP Radio is attached |
| baudrate           | Serial port baudrate (depends on firmware)   |
| flow_control       | If hardware flow control should be enabled (depends on firmware) |
| autoflash_firmware | Automatically install/update firmware (Home Assistant SkyConnect/Yellow) |
| otbr_log_level     | Set the log level of the OpenThread BorderRouter Agent     |
| firewall           | Enable OpenThread Border Router firewall to block unnecessary traffic |

## Support

Got questions?

You have several options to get them answered:

- The [Home Assistant Discord Chat Server][discord].
- The Home Assistant [Community Forum][forum].
- Join the [Reddit subreddit][reddit] in [/r/homeassistant][reddit]

In case you've found a bug, please [open an issue on our GitHub][issue].

[discord]: https://discord.gg/c5DvZ4e
[forum]: https://community.home-assistant.io
[reddit]: https://reddit.com/r/homeassistant
[issue]: https://github.com/home-assistant/addons/issues
[openthread-platforms]: https://openthread.io/platforms
[nordic-nrf52840-dongle]: https://www.nordicsemi.com/Products/Development-hardware/nrf52840-dongle
[nordic-nrf52840-dongle-install]: https://developer.nordicsemi.com/nRF_Connect_SDK/doc/latest/matter/openthread_rcp_nrf_dongle.html

