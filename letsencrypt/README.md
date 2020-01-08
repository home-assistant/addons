# Hass.io Core Add-on: Letsencrypt

Let's Encrypt is a certificate authority that provides free X.509 certificates for Transport Layer Security encryption via an automated process designed to eliminate the hitherto complex process of manual creation, validation, signing, installation, and renewal of certificates for secure websites.

![Supports aarch64 Architecture][aarch64-shield] ![Supports amd64 Architecture][amd64-shield] ![Supports armhf Architecture][armhf-shield] ![Supports armv7 Architecture][armv7-shield] ![Supports i386 Architecture][i386-shield]

## About

Setting up Letsencrypt allows you to use validated certificates for your webpages and webinterfaces.
It requires you to own the domain you are requesting the certificate for.

The generated certificate can be used within others addons.

## Installation

Follow these steps to get the add-on installed on your system:

1. Navigate in your Home Assistant frontend to **Hass.io** -> **Add-on Store**.
2. Find the "letsencrypt" add-on and click it.
3. Click on the "INSTALL" button.

## How to use

To use this add-on, you have two options on how to get your certificate:

1. http challenge:
   - Requires Port 80 to be available from the internet and your domain assigned to the externally assigned IP address
   - Doesnt allow wildcard certificates (*.yourdomain.com).

2. dns challenge
   - Requires you to use one of the supported DNS providers (See "Supported DNS providers" below)
   - Allows to request wildcard certificates (*.yourdomain.com)
   - Doesn’t need you to open a port to your hass.io host on your router.

You always need to provide the following entries within the configuration:

```json
  "email": "your@email.com"
  "domains": "yourdomain.com" // use "*.yourdomain.com" for wildcard certificates.
  "challenge": "http OR dns"
```

IF you choose "dns" as "challenge", you will also need to fill:

```json
  "dnsprovider": "" (Add the dnsprovider of your choice from the list of "Supported DNS providers" below)
```

In addition add the fields according to the credentials required by your dns provider:

```json
"cloudflare_email": "",
"cloudflare_api_key": "",
"cloudxns_api_key": "",
"cloudxns_secret_key": "",
"digitalocean_token": "",
"dnsimple_token": "",
"dnsmadeeasy_api_key": "",
"dnsmadeeasy_secret_key": "",
"gehirn_api_token": "",
"gehirn_api_secret": "",
"linode_key": "",
"linode_version": "",
"luadns_email": "",
"luadns_token": "",
"nsone_api_key": "",
"ovh_endpoint": "",
"ovh_application_key": "",
"ovh_application_secret": "",
"ovh_consumer_key": "",
"rfc2136_server": "",
"rfc2136_port": "",
"rfc2136_name": "",
"rfc2136_secret": "",
"rfc2136_algorithm": "",
"aws_access_key_id": "",
"aws_secret_access_key": "",
"sakuracloud_api_token": "",
"sakuracloud_api_secret": ""
```

## Configuration

Add-on configuration:

```json
{
  "email": "hello@home-assistant.io",
  "domains": [
    "home-assistant.io"
  ],
  "challenge": "dns",
  "dns": {
    "provider": "dns-cloudflare",
    "cloudflare_email": "cf@home-assistant.io",
    "cloudflare_api_key": "31242lk3j4ljlfdwsjf0"
  }
}
```

## Supported DNS providers

```json
dns-cloudflare
dns-cloudxns
dns-digitalocean
dns-dnsimple
dns-dnsmadeeasy
dns-gehirn
dns-google (Currently not fully implemented)
dns-linode
dns-luadns
dns-nsone
dns-ovh
dns-rfc2136
dns-route53
dns-sakuracloud
```

## Known issues and limitations

- Currently the google dns provider is not supported. Let us know if you want to use google, so we can test the required settings together.

## Support

Got questions?

You have several options to get them answered:

- The [Home Assistant Discord Chat Server][discord].
- The Home Assistant [Community Forum][forum].
- Join the [Reddit subreddit][reddit] in [/r/homeassistant][reddit]
- Check out certbots page [certbot].

In case you've found a bug, please [open an issue on our GitHub][issue].

[aarch64-shield]: https://img.shields.io/badge/aarch64-yes-green.svg
[amd64-shield]: https://img.shields.io/badge/amd64-yes-green.svg
[armhf-shield]: https://img.shields.io/badge/armhf-yes-green.svg
[armv7-shield]: https://img.shields.io/badge/armv7-yes-green.svg
[i386-shield]: https://img.shields.io/badge/i386-yes-green.svg
[discord]: https://discord.gg/c5DvZ4e
[forum]: https://community.home-assistant.io
[issue]: https://github.com/home-assistant/hassio-addons/issues
[certbot]: https://certbot.eff.org
[reddit]: https://reddit.com/r/homeassistant
