# Home Assistant App: NGINX Home Assistant SSL proxy

Sets up an SSL proxy with NGINX and redirects traffic from port 80 to 443.

![Supports aarch64 Architecture][aarch64-shield] ![Supports amd64 Architecture][amd64-shield]

## About

Sets up an SSL proxy with NGINX web server. It is typically used to forward SSL internet traffic while allowing unencrypted local traffic to/from a Home Assistant instance.

Make sure you have generated a certificate before you start this app. The [Duck DNS](https://github.com/home-assistant/hassio-addons/tree/master/duckdns) app can generate a Let's Encrypt certificate that can be used by this app.

[aarch64-shield]: https://img.shields.io/badge/aarch64-yes-green.svg
[amd64-shield]: https://img.shields.io/badge/amd64-yes-green.svg
