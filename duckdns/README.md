# Home Assistant Add-on: DuckDNS

Automatically update your Duck DNS IP address with integrated HTTPS support via Let's Encrypt.

DUE to a configuration bug in the UI, please edit the domain list in your YAML to look like this- (the domain format needs to be a list)

domains:
  - Yoursubdomain.duckdns.org
  - secondsubdomain.duckdns.org
token: []
aliases: []
lets_encrypt:
  accept_terms: false
  algo: secp384r1
  certfile: fullchain.pem
  keyfile: privkey.pem
seconds: 300



![Supports aarch64 Architecture][aarch64-shield] ![Supports amd64 Architecture][amd64-shield] ![Supports armhf Architecture][armhf-shield] ![Supports armv7 Architecture][armv7-shield] ![Supports i386 Architecture][i386-shield]

## About

[Duck DNS][duckdns] is a free service that points a DNS (sub-domains of duckdns.org) to an IP of your choice. This add-on includes support for Let’s Encrypt and automatically creates and renews your certificates. You need to sign up for a Duck DNS account before using this add-on.

[aarch64-shield]: https://img.shields.io/badge/aarch64-yes-green.svg
[amd64-shield]: https://img.shields.io/badge/amd64-yes-green.svg
[armhf-shield]: https://img.shields.io/badge/armhf-yes-green.svg
[armv7-shield]: https://img.shields.io/badge/armv7-yes-green.svg
[i386-shield]: https://img.shields.io/badge/i386-yes-green.svg
[duckdns]: https://www.duckdns.org

