# Home Assistant Add-on: Dnsmasq

A simple DNS server.

![Supports aarch64 Architecture][aarch64-shield] ![Supports amd64 Architecture][amd64-shield] ![Supports armhf Architecture][armhf-shield] ![Supports armv7 Architecture][armv7-shield] ![Supports i386 Architecture][i386-shield]

## About

Setup and manage a Dnsmasq DNS server. This allows you to manipulate DNS
requests. For example, you can have your Home Assistant domain resolve with
an internal address inside your network.

## Installation

Follow these steps to get the add-on installed on your system:

1. Navigate in your Home Assistant frontend to **Supervisor** -> **Add-on Store**.
2. Find the "Dnsmasq" add-on and click it.
3. Click on the "INSTALL" button.

## How to use

The add-on has a couple of options available. For more detailed instructions
see below. The basic thing to get the add-on running would be:

1. Start the add-on.

## Configuration

The Dnsmasq add-on can be tweaked to your likings. This section
describes each of the add-on configuration options.

Example add-on configuration:

```yaml
defaults:
  - 8.8.8.8
  - 8.8.4.4
forwards:
  - domain: mystuff.local
    server: 192.168.1.40
hosts:
  - host: home.mydomain.io
    ip: 192.168.1.10
```

### Option: `defaults` (required)

The defaults are upstream DNS servers, where DNS requests that can't
be handled locally, are forwarded to. By default it is configured to have
Google's public DNS servers: `"8.8.8.8", "8.8.4.4".

### Option: `forwards` (optional)

This option allows you to list domain that are forwarded to a different
(not the default) upstream DNS server.

#### Option: `forwards.domain`

The domain to forward to a different upstream DNS server.

#### Option: `forwards.server`

The DNS server to forward the request for this domain to.

### Option: `hosts` (optional)

This option allows you to provide local static answer for your DNS server.

This is helpful for making addresses resolve on your internal network and
even override external domains to be answered with a local address.

For example, one could set `myuser.duckdns.org` to resolve directly to a
internal IP address, e.g., `192.168.1.10`. While outside of this network,
it would resolve normally.

This options allows you to create a so called: Split DNS.

#### Option: `hosts.host`

The hostname or domainname to resolve locally.

#### Option: `hosts.ip`

The IP address Dnsmasq should respond with in its DNS answer.

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
