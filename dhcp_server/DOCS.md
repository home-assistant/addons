# Home Assistant Add-on: DHCP Server

## Installation

Follow these steps to install the DHCP add-on:

1. Navigate in your Home Assistant frontend to **Settings** -> **Add-ons** -> **Add-on store**.
2. Find and click the "DHCP server" add-on.
3. Click the "INSTALL" button.
4. Modify the configuration as needed.

## How to Use

1. Set the `domain` option, e.g., `mynetwork.internal`.
2. Save the configuration by clicking the "SAVE" button.
3. Start the add-on.

## Configuration

The DHCP server add-on can be customized to suit your needs. This section describes all of the configuration options.

Example configuration:

```yaml
domain: mynetwork.internal
dns:
  - 8.8.8.8
  - 8.8.4.4
ntp:
  - 192.168.1.0
  - pool.ntp.org
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
  - name: bedroom-switch
    mac: aa:bb:cc:dd:ee:ff
    ip: 192.168.1.40
```

### Option: `domain` (required)

The domain name for your network, e.g., `home.internal` or `home.local` (be aware that issues exist with using `.local` for DHCP/DNS)

### Option: `dns` (required)

The DNS (Name Servers) provided to clients. This option can
contain a list of servers.  By default, Google's public DNS servers are included: `8.8.8.8`, `8.8.4.4`.

### Option: `ntp` (required)

The NTP servers (Network Time Protocol) provided to clients. By default, no servers are included (`[]`).

### Option: `default_lease` (required)

The default lease time in seconds. Defaults to `86400` (one day).

### Option: `max_lease` (required)

The maximum lease time in seconds. Defaults to `172800` (two days).

### Option: `networks` (at least one item required)

Defines one or more IP address ranges ("networks"). For example, `192.168.1.0` to `192.168.1.255` (also expressed as a Class-C network: `192.168.1.0/24`).

A minimum of one network is required. Example:
```yaml
networks:
  - subnet: 192.168.1.0
    netmask: 255.255.255.0
    range_start: 192.168.1.100
    range_end: 192.168.1.200    
    gateway: 192.168.1.1
    interface: eth0
    broadcast: 192.168.1.255
```

#### Option: `networks.subnet`

The first IP of the network. For example, if your IP addresses are `192.168.1.x`, the subnet is `192.168.1.0`.

#### Option: `networks.netmask`

The network netmask. Typically `255.255.255.0` for a class-C network, which includes addresses from `x.x.x.0` to `x.x.x.255` (254 usable addresses).

A class-B network would have a netmask of `255.255.0.0`, covering addresses from `x.x.0.0` to `x.x.255.255` (65,534 usable addresses).

If unsure, use `255.255.255.0`.

#### Option: `networks.range_start`

The start IP address for the DHCP lease range. Used with `range_end` to define the range of IP's available for lease by the DHCP server.

#### Option: `networks.range_end`

The last IP address for the range of IP addresses available for lease by the DHCP server.

#### Option: `networks.broadcast`

The broadcast IP address of the network, typically the first three octets of your class-C network plus `.255`, e.g., `192.168.1.255` for `192.168.1.0`.

#### Option: `networks.gateway`

The router (gateway) address where traffic is routed from your network onto the Internet.

This is typically the first three octets of your class-C network plus `.1`, e.g., `192.168.1.1` for `192.168.1.0`.

This is required. If this address is missing or wrong, traffic will not flow onto the Internet.

#### Option: `networks.interface`

The network interface to listen on, e.g., `eth0`, the default for Home Assistant OS.

### Option: `hosts` (optional)

A list of hosts to be assigned fixed IP addresses. Requires the host's MAC address.

Fixed IP addresses can be anywhere within the network, as long as they are not duplicates.  They are not required to be within the `range_start` and `range_end`. This range is for dynamically allocated IP addresses.

By default, no hosts are configured and none are required for DHCP server function.

Example:
```yaml
hosts:
  - name: MyRouter
    mac: aa:bb:cc:dd:ee:ff
    ip: 192.168.1.1
    6: 94.140.14.15  # Option 6 w/Family-Friendly DNS Server (AdGuard)
```

#### Option: `hosts.name`

The name of the host (client) to be assigned a fixed IP address.

#### Option: `hosts.mac`

The MAC address of the host (client) device.

#### Option: `hosts.ip`

The IP address assigned to the host (client) device.

#### Option: Number between 1 - 254

For advanced users, you may choose to include numbered DHCP options.

For example, you may prefer an alternative DNS server for your Router or Children's PC's, that DNS server can be assigned with **Option 6.**

Assign a custom domain name using **Option 15.**

Assign a TFTP server for flashing devices using **Option 66.**

Assign a NetBIOS name server to speed local name resolution on Windows networks using **Option 44.**

## Support

Got questions?

You have several options to get them answered:

- The [Home Assistant Discord Chat Server][discord].
- The Home Assistant [Community Forum][forum].
- Join the [Reddit subreddit][reddit] in [/r/homeassistant][reddit]

In case you've found a bug, please [open an issue on our GitHub][issue].

[discord]: https://discord.gg/c5DvZ4e
[forum]: https://community.home-assistant.io
[issue]: https://github.com/home-assistant/addons/issues
[reddit]: https://reddit.com/r/homeassistant
[repository]: https://github.com/hassio-addons/repository