# Home Assistant Add-on: Letsencrypt

## Installation

Follow these steps to get the add-on installed on your system:

1. Navigate in your Home Assistant frontend to **Supervisor** -> **Add-on Store**.
2. Find the "letsencrypt" add-on and click it.
3. Click on the "INSTALL" button.

## How to use

To use this add-on, you have two options on how to get your certificate:

### 1. http challenge

- Requires Port 80 to be available from the internet and your domain assigned to the externally assigned IP address
- Doesnt allow wildcard certificates (*.yourdomain.com).

### 2. dns challenge

- Requires you to use one of the supported DNS providers (See "Supported DNS providers" below)
- Allows to request wildcard certificates (*.yourdomain.com)
- Doesn’t need you to open a port to your Home Assistant host on your router.

### You always need to provide the following entries within the configuration

```yaml
email: your@email.com
domains:
  # use "*.yourdomain.com" for wildcard certificates.
  - yourdomain.com
challenge: http OR dns
```

IF you choose "dns" as "challenge", you will also need to fill:

```yaml
# Add the dnsprovider of your choice from the list of "Supported DNS providers" below
dns:
  provider: ""
```

In addition add the fields according to the credentials required by your dns provider:


```yaml
propagation_seconds: 60
cloudflare_email: ''
cloudflare_api_key: ''
cloudflare_api_token: ''
cloudxns_api_key: ''
cloudxns_secret_key: ''
digitalocean_token: ''
directadmin_url: ''
directadmin_username: ''
directadmin_password: ''
dnsimple_token: ''
dnsmadeeasy_api_key: ''
dnsmadeeasy_secret_key: ''
google_creds: ''
gehirn_api_token: ''
gehirn_api_secret: ''
linode_key: ''
linode_version: ''
luadns_email: ''
luadns_token: ''
nsone_api_key: ''
ovh_endpoint: ''
ovh_application_key: ''
ovh_application_secret: ''
ovh_consumer_key: ''
rfc2136_server: ''
rfc2136_port: ''
rfc2136_name: ''
rfc2136_secret: ''
rfc2136_algorithm: ''
aws_access_key_id: ''
aws_secret_access_key: ''
sakuracloud_api_token: ''
sakuracloud_api_secret: ''
netcup_customer_id: ''
netcup_api_key: ''
netcup_api_password: ''
gandi_api_key: ''
gandi_sharing_id: ''
transip_username: ''
transip_api_key: ''
```

## Advanced

### Changing the ACME Server
By default, The addon uses Let’s Encrypt’s default server at https://acme-v02.api.letsencrypt.org/. You can instruct the addon to use a different ACME server by providing the field `acme_server` with the URL of the server’s ACME directory:

```yaml
acme_server: 'https://my.custom-acme-server.com'
```

If your custom ACME server uses a certificate signed by an untrusted certificate authority (CA), you can add the root certificate to the trust store by setting its content as an option:
```yaml
acme_server: 'https://my.custom-acme-server.com'
acme_root_ca_cert: |
  -----BEGIN CERTIFICATE-----
  MccBfTCCASugAwIBAgIRAPPIPTKNBXkBozsoE46UPZcwCGYIKoZIzj0EAwIwHTEb...kg==
  -----END CERTIFICATE-----
```

## Example Configurations

### http challenge

```yaml
email: your.email@example.com
domains:
  - home-assistant.io
certfile: fullchain.pem
keyfile: privkey.pem
challenge: http
dns: {}
```

### dns challenge

```yaml
email: your.email@example.com
domains:
  - home-assistant.io
certfile: fullchain.pem
keyfile: privkey.pem
challenge: dns
dns:
  provider: dns-cloudflare
  cloudflare_email: your.email@example.com
  cloudflare_api_key: 31242lk3j4ljlfdwsjf0
```

### google dns challenge

```yaml
email: your.email@example.com
domains:
  - home-assistant.io
certfile: fullchain.pem
keyfile: privkey.pem
challenge: dns
dns:
  provider: dns-google
  google_creds: google.json
```

Please copy your credentials file "google.json" into the "share" shared folder on the Home Assistant host before starting the service.

One way is to use the "Samba" add on to make the folder available via network or SSH Add-on.

The credential file can be created and downloaded when creating the service user within the Google cloud.
You can find additional information in regards to the required permissions in the "credentials" section here:

<https://github.com/certbot/certbot/blob/master/certbot-dns-google/certbot_dns_google/__init__.py>

### route53 dns challenge

```yaml
email: your.email@example.com
domains:
  - home-assistant.io
certfile: fullchain.pem
keyfile: privkey.pem
challenge: dns
dns:
  provider: dns-route53
  aws_access_key_id: 0123456789ABCDEF0123
  aws_secret_access_key: 0123456789abcdef0123456789/abcdef0123456
```

For security reasons, don't use your main account's credentials. Instead, add a new [AWS user](https://console.aws.amazon.com/iam/home?#/users) with _Access Type: Programmatic access_ and use that user's access key. Assign a minimum [policy](https://console.aws.amazon.com/iam/home?#/policies$new?step=edit) like the following example. Make sure to replace the Resource ARN in the first statement to your domain's hosted zone ARN or use _*_ for all.

```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "ChangeSpecificDomainsRecordSet",
            "Effect": "Allow",
            "Action": "route53:ChangeResourceRecordSets",
            "Resource": "arn:aws:route53:::hostedzone/01234567890ABC"
        },
        {
            "Sid": "ListAllHostedZones",
            "Effect": "Allow",
            "Action": "route53:ListHostedZones",
            "Resource": "*"
        },
        {
            "Sid": "ReadChanges",
            "Effect": "Allow",
            "Action": "route53:GetChange",
            "Resource": "arn:aws:route53:::change/*"
        }
    ]
}
```

### CloudFlare

Previously, Cloudflare’s “Global API Key” was used for authentication, however this key can access the entire Cloudflare API for all domains in your account, meaning it could cause a lot of damage if leaked.

Cloudflare’s newer API Tokens can be restricted to specific domains and operations, and are therefore now the recommended authentication option.

However, due to some shortcomings in Cloudflare’s implementation of Tokens, Tokens created for Certbot currently require `Zone:Zone:Read` and `Zone:DNS:Edit` permissions for all zones in your account.

Example credentials file using restricted API Token (recommended):
```yaml
dns:
  provider: dns-cloudflare
  cloudflare_api_token: 0123456789abcdef0123456789abcdef01234
```

Example credentials file using Global API Key (not recommended):
```yaml
dns:
  provider: dns-cloudflare
  cloudflare_email: cloudflare@example.com
  cloudflare_api_key: 0123456789abcdef0123456789abcdef01234
```

### DirectAdmin

It is recommended to create a login key in the DirectAdmin control panel to be used as value for directadmin_password.
Instructions on how to create such key can be found at https://help.directadmin.com/item.php?id=523.

Make sure to grant the following permissions:
- `CMD_API_LOGIN_TEST`
- `CMD_API_DNS_CONTROL`
- `CMD_API_SHOW_DOMAINS`

Username and password can also be used in case your DirectAdmin instance has no support for login keys.

Example configuration:
```yaml
email: mail@domain.tld
domains:
  - your.domain.tld
certfile: fullchain.pem
keyfile: privkey.pem
challenge: dns
dns:
  propagation_seconds: 60
  provider: dns-directadmin
  directadmin_url: 'https://domain.tld:2222/'
  directadmin_username: da_user
  directadmin_password: da_password_or_key
```

### TransIP

You will need to generate an API key from the TransIP Control Panel at https://www.transip.nl/cp/account/api/.

The propagation limit will be automatically raised to 240 seconds.

Example configuration:
```yaml
email: your.email@example.com
domains:
  - your.domain.tld
certfile: fullchain.pem
keyfile: privkey.pem
challenge: dns
dns:
  provider: dns-transip
  transip_username: transip-user
  transip_api_key: |
    -----BEGIN PRIVATE KEY-----
    MII..ABCDEFGHIJKLMNOPQRSTUVWXYZ
    AAAAAABCDEFGHIJKLMNOPQRSTUVWXYZ
    -----END PRIVATE KEY-----
```

### OVH
You will need to generate an OVH API Key first at https://eu.api.ovh.com/createToken/ (for Europe) or https://ca.api.ovh.com/createToken/ (for north america). 

When creating the API Key, you must ensure that the following rights are granted:
* ``GET /domain/zone/*``
* ``PUT /domain/zone/*``
* ``POST /domain/zone/*``
* ``DELETE /domain/zone/*``

Example configuration
```yaml
email: your.email@example.com
domains:
  - home-assistant.io
certfile: fullchain.pem
keyfile: privkey.pem
challenge: dns
dns:
  provider: dns-ovh
  ovh_endpoint: ovh-eu
  ovh_application_key: 0123456789abcdef0123456789abcdef01234
  ovh_application_secret: 0123456789abcdef0123456789abcdef01234
  ovh_consumer_key: 0123456789abcdef0123456789abcdef01234
```
Use `ovh_endpoint: ovh-ca` for north america region.


## Certificate files

The certificate files will be available within the "ssl" share after successful request of the certificates.

By default other addons are referring to the correct path of the certificates.
You can in addition find the files via the "samba" addon within the "ssl" share.

## Supported DNS providers

```txt
dns-cloudflare
dns-cloudxns
dns-digitalocean
dns-directadmin
dns-dnsimple
dns-dnsmadeeasy
dns-gehirn
dns-google
dns-linode
dns-luadns
dns-nsone
dns-ovh
dns-rfc2136
dns-route53
dns-sakuracloud
dns-netcup
dns-gandi
dns-transip
```

## Support

Got questions?

You have several options to get them answered:

- The [Home Assistant Discord Chat Server][discord].
- The Home Assistant [Community Forum][forum].
- Join the [Reddit subreddit][reddit] in [/r/homeassistant][reddit]
- Check out certbots page [certbot].

In case you've found a bug, please [open an issue on our GitHub][issue].

[discord]: https://discord.gg/c5DvZ4e
[forum]: https://community.home-assistant.io
[issue]: https://github.com/home-assistant/hassio-addons/issues
[certbot]: https://certbot.eff.org
[reddit]: https://reddit.com/r/homeassistant
