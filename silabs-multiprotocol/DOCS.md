# Home Assistant Add-on: Silicon Labs Multiprotocol

**NOTE**: This add-on has the option to automatically install the right firmware for Home Assistant Yellow, SkyConnect, and Connect ZBT-1. Follow [this guide](https://github.com/NabuCasa/silabs-firmware/wiki/Flash-Silicon-Labs-radio-firmware-manually) to change back to a firmware that is compatible with other Zigbee software.

## Installation

Follow these steps to get the add-on installed on your system:

1. Navigate in your Home Assistant frontend to **Settings** -> **Add-ons, Backup & Supervisor** -> **Add-on Store**.
2. Find the "Silicon Labs Multiprotocol" add-on and click it.
3. Click on the "INSTALL" button.

## How to use

The add-on needs a Silicon Labs based wireless module accessible through a
serial port (like the module on Yellow or most USB based wireless adapters).

Once the firmware is loaded follow the following steps:

1. Select the correct `device` in the add-on configuration tab and press `Save`.
   On Home Assistant Yellow use `/dev/ttyAMA1`.
2. Start the add-on.

**NOTE:** the Web frontend is only accessible when OpenThread is enabled (see below).

### Zigbee

To use Zigbee with ZHA configure the Integration as follows:

1. Remember/copy the hostname of the add-on (e.g. `c8f00288-silabs-multiprotocol`).
2. Add the Zigbee Home Automation (ZHA) integration to Home Assistant Core
3. When asked for the Serial Device Path, choose `Enter Manually`.
4. Choose `EZSP` as Radio type.
5. As serial path, enter `socket://<hostname-from-above>:9999`.
6. Port speed and flow control don't matter.
7. Press `Submit`. Adding ZHA should succeed and you should be able to use ZHA
   as if using any other supported radio type.

### OpenThread

At this point OpenThread support is experimental. This add-on makes your Home
Assistant installation an OpenThread Border Router (OTBR). A basic integration
for Home Assistant Core named `otbr` is currently in the making.

To use the OTBR enable it in the Configuration tab and restart the add-on. Home
Assistant should discover the OpenThread border router automatically and
configure it as necessary.

### Web interface (advanced)

There is also a web interface provided by the OTBR. However, the web
interface has caveats (e.g. forming a network does not generate an off-mesh
routable IPv6 prefix which causes changing IPv6 addressing on first add-on
restart). It is still possible to enable the web interface for debugging
purpose. Make sure to expose both the Web UI port and REST API port (the
latter needs to be on port 8081) on the host interface. To do so, click on
"Show disabled ports" and enter a port (e.g. 8080) in the OpenThread Web UI
and 8081 in the OpenThread REST API port field).

### Automatic firmware upgrade

If the `autoflash_firmware` configuration is set, the add-on will automatically
install or update to the RCP Multi-PAN firmware if a Home Assistant Connect ZBT-1/
SkyConnect or Home Assistant Yellow is detected.

**NOTE:** Switching back to a Zigbee only (EmberZNet) firmware requires manual
steps currently. You can find a guide on the Nabu Casa Silicon Labs firmware
repository Wiki on flashing [Silicon Labs radio firmware
manually](https://github.com/NabuCasa/silabs-firmware/wiki/Flash-Silicon-Labs-radio-firmware-manually).

## Configuration

Add-on configuration:

| Configuration      | Description                                            |
|--------------------|--------------------------------------------------------|
| device (mandatory) | Serial service where the Silicon Labs radio is attached |
| baudrate           | Serial port baudrate (depends on firmware)   |
| flow_control       | If hardware flow control should be enabled (depends on firmware) |
| autoflash_firmware | Automatically install/update firmware (Home Assistant Connect ZBT-1/SkyConnect/Yellow) |
| network_device     | Host and port where CPC daemon can find the Silicon Labs radio (takes precedence over device) |
| cpcd_trace         | Co-Processor Communication tracing (trace in log)      |
| otbr_enable        | Enable OpenThread BorderRouter                         |
| otbr_log_level     | Set the log level of the OpenThread BorderRouter Agent     |
| otbr_firewall      | Enable OpenThread Border Router firewall to block unnecessary traffic |
| otbr_nat64         | Enable OpenThread Border Router NAT64 to allow Thread devices accessing IPv4 addresses |

## Architecture

The add-on runs several service internally. This architecture diagram shows what
the add-on currently implements.

![Silicon Labs Multiprotocol Add-on Architecture](https://raw.githubusercontent.com/home-assistant/addons/master/silabs-multiprotocol/images/architecture.png)

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
