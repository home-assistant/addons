# Hass.io Core Add-on: DHCP server

A simple DHCP server.

![Supports aarch64 Architecture][aarch64-shield] ![Supports amd64 Architecture][amd64-shield] ![Supports armhf Architecture][armhf-shield] ![Supports armv7 Architecture][armv7-shield] ![Supports i386 Architecture][i386-shield]

## About

This add-on provides a simple DHCP server for your network.
It provides some basic needs, like, reserving IP addresses for your devices
to ensure they always get assigned the same IP address.

## Installation

The installation of this add-on is straightforward and easy to do.

1. Navigate in your Home Assistant frontend to **Hass.io** -> **Add-on Store**.
2. Find the "DHCP server" add-on and click it.
3. Click on the "INSTALL" button.

## How to use

1. Set the `domain` option, e.g., `mynetwork.local`.
2. Save the add-on configuration by clicking the "SAVE" button.
3. Start the add-on.

## Configuration

The DHCP server add-on can be tweaked to your likings. This section
describes each of the add-on configuration options.

Example add-on configuration:

```json
{
  "domain": "mynetwork.local",
  "dns": ["8.8.8.8", "8.8.4.4"],
  "default_lease": 86400,
  "max_lease": 172800,
  "networks": [
    {
      "subnet": "192.168.1.0",
      "netmask": "255.255.255.0",
      "range_start": "192.168.1.100",
      "range_end": "192.168.1.200",
      "broadcast": "192.168.1.255",
      "gateway": "192.168.1.1",
      "interface": "eth0"
    }
  ],
  "hosts": [
    {
      "name": "webcam_xy",
      "mac": "aa:bb:ee:cc",
      "ip": "192.168.1.40"
    }
  ]
}
```

### Option: `domain` (required)

Your network domain name, e.g., `mynetwork.local` or `home.local`

### Option: `dns` (required)

The DNS servers you DHCP server gives to your clients. This option can
contain a list of servers. By default it is configured to have Google's
public DNS servers: `"8.8.8.8", "8.8.4.4".

### Option: `default_lease` (required)

The default time in seconds that the IP is leased to your client.
Defaults to `86400`, which is one day.

### Option: `max_lease` (required)

The max time in seconds that the IP is leased to your client.
Defaults to `172800`, which is two days.

### Option: `networks` (one item required)

This option defines settings for one or multiple networks for the DHCP server
to hand out IP addresses for.

At least one network definition in your configuration is required for the
DHCP server to work.

#### Option: `networks` -> `subnet`

Your network schema/subnet. For example, if your IP addresses are `192.168.1.x`
the subnet becomes `192.168.1.0`.

#### Option: `networks` -> `netmask`

Your network netmask. For example, if your IP addresses are `192.168.1.x` the
netmask becomes `255.255.255.0`.

#### Option: `networks` -> `range_start`

Defines the start IP address for the DHCP server to lease IPs for.
Use this together with the `range_end` option to define the range of IP
addresses the DHCP server operates in.

#### Option: `networks` -> `range_end`

Defines the end IP address for the DHCP server to lease IPs for.

#### Option: `networks` -> `broadcast`

The broadcast address specific to the lease range. For example, if your
IP addresses are `192.168.1.x`, the broadcast address is usually `192.168.1.255`.

#### Option: `networks` -> `gateway`

Sets the gateway address for that the DHCP server hands out to its clients.
This is usually the IP address of your router.

#### Option: `networks` -> `interface`

The network interface to listen to for this network, e.g., `eth0`.

### Option: `hosts` (optional)

This option defines settings for one or host definitions for the DHCP server.

It allows you to fix a host to a specific IP address.

By default, non are configured.

#### Option: `hosts` -> `name`

The name of the hostname you'd like to fix an address for.

#### Option: `hosts` -> `mac`

The MAC address of the client device.

#### Option: `hosts` -> `ip`

The IP address you want the DHCP server to assign.

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
