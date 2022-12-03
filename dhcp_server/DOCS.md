# Home Assistant Add-on: DHCP server

## Installation

Follow these steps to get the add-on installed on your system:

1. Navigate in your Home Assistant frontend to **Supervisor** -> **Add-on Store**.
2. Find the "DHCP server" add-on and click it.
3. Click on the "INSTALL" button.
4. Modify configuration as needed

## How to use

1. Set the `domain` option, e.g., `mynetwork.local`.
2. Save the add-on configuration by clicking the "SAVE" button.
3. Start the add-on.

## Configuration

The DHCP server add-on can be tweaked to your likings. This section
describes each of the add-on configuration options.

Example add-on configuration:

```yaml
domain: mynetwork.local
dns:
  - 8.8.8.8
  - 8.8.4.4
ntp:
  - 192.168.1.0
default_lease: 86400
max_lease: 172800
networks:
  - subnet: 192.168.1.0
    netmask: 255.255.255.0
    range_start: 192.168.1.100
    range_end: 192.168.1.200
    broadcast: 192.168.1.255
    gateway: 192.168.1.1
    interface: eth0
hosts:
  - name: webcam_xy
    mac: aa:bb:ee:cc
    ip: 192.168.1.40
static_routes:
  - subnet: 192.168.1.0
    network: 192.168.2
    mask: 24
    gateway: 192.168.1.2
```

### Option: `domain` (required)

Your network domain name, e.g., `mynetwork.local` or `home.local`

### Option: `dns` (required)

The DNS servers your DHCP server gives to your clients. This option can
contain a list of servers. By default, it is configured to have Google's
public DNS servers: `"8.8.8.8", "8.8.4.4".

### Option `ntp` (required)

The NTP servers your DHCP server gives to your clients.  This option can
contain a list of server.  By default, none are configured ([])

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

#### Option: `networks.subnet`

Your network schema/subnet. For example, if your IP addresses are `192.168.1.x`
the subnet becomes `192.168.1.0`.

#### Option: `networks.netmask`

Your network netmask. For example, if your IP addresses are `192.168.1.x` the
netmask becomes `255.255.255.0`.

#### Option: `networks.range_start`

Defines the start IP address for the DHCP server to lease IPs for.
Use this together with the `range_end` option to define the range of IP
addresses the DHCP server operates in.

#### Option: `networks.range_end`

Defines the end IP address for the DHCP server to lease IPs for.

#### Option: `networks.broadcast`

The broadcast address specific to the lease range. For example, if your
IP addresses are `192.168.1.x`, the broadcast address is usually `192.168.1.255`.

#### Option: `networks.gateway`

Sets the gateway address for that the DHCP server hands out to its clients.
This is usually the IP address of your router.

#### Option: `networks.interface`

The network interface to listen to for this network, e.g., `eth0`.

### Option: `hosts` (optional)

This option defines settings for one or host definitions for the DHCP server.

It allows you to fix a host to a specific IP address.

By default, non are configured.

#### Option: `hosts.name`

The name of the hostname you'd like to fix an address for.

#### Option: `hosts.mac`

The MAC address of the client device.

#### Option: `hosts.ip`

The IP address you want the DHCP server to assign.

### Option: `static_routes` (optional)

This option defines settings for DHCP option 121 (Classless Static Route).
It allows you to inject static network route with DHCP configuration.

By default, non are configured.

#### Option: `static_routes.subnet`

The network schema/subnet (`networks.subnet`) for which the rule will apply.

#### Option: `static_routes.network`

Subnet address for which traffic is to be redirected.

If the octet belongs entirely to the network part then it should not be given, e.g. `192.168.2.0/24` -> `192.168.2`, `172.16.0.0/16` -> `172.16`.

#### Option: `static_routes.mask`

The network mask in CIDR format e.g. `24`.

#### Option: `static_routes.gateway`

The network address to which traffic will be redirected.

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
[repository]: https://github.com/hassio-addons/repository
