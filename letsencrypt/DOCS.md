
# Home Assistant Add-on: Let's Encrypt

Additional Let's Encrypt setup instructions can be [found here](https://www.home-assistant.io/blog/2015/12/13/setup-encryption-using-lets-encrypt/).

## Installation

Follow these steps to get the add-on installed on your system:

1. Navigate in your Home Assistant frontend to [Settings → Add-ons → Add-on store](https://my.home-assistant.io/redirect/supervisor_store/).
2. Find the [Let's Encrypt](https://my.home-assistant.io/redirect/supervisor_addon/?addon=core_letsencrypt) add-on and click it.
3. Click on the **Install** button.

## How to use

**Provide the required configuration:**
- **Domain**
	- The domain (or usually subdomain) that you want the SSL certificate for.
- **Email**
	- The email address that Let's Encrypt will use to register your SSL certificate.
- **Private Key File**
	- Keep this the same unless you just want to change it.
- **Certificate File**
	- Keep this the same unless you just want to change it.
- **Challenge**
	- To use this add-on, you have two options on how to validate your domain:
		1. **HTTP challenge**
			- Requires Port 80 to be available from the internet and your domain assigned to the externally assigned IP address. This means you have to configure port forwarding. Note that most residential ISPs do NOT allow access to port 80 on your network. If you have a business account with your ISP they may allow it.
			- Doesn’t allow wildcard certificates (*.yourdomain.com).
			- Although this method sounds easier at first, it probably won't work if you're on a residential connection. When you're sure you have a port open, you can verify port connectivity with a site like [PortChecker.co](https://portchecker.co/).
		2. **DNS challenge**
			- Requires you to use one of the supported DNS providers.
			- Allows to request wildcard certificates (*.yourdomain.com).
			- Home Assistant does not need to be publicly accessible - no need to configure port forwarding.
			- Take a few minutes longer but is probably the best choice.


If you choose **dns** as the **Challenge**, you will need to fill in the DNS section. These entries would be the same as in your config under the `dns:` line. You will need to specify the provider exactly as it appears on the list of **Supported DNS Providers** and the associated credential key/value (such as API key /secret).

**Example using Cloudflare w/token:**

![Example DNS](https://github-production-user-asset-6210df.s3.amazonaws.com/49938263/264420168-307d9fb3-f9f8-455c-bc2d-4b66b8b05e7b.png)

## Supported DNS Providers

Find your DNS provider and use the value as shown below as the value for `provider:` in the **DNS** textarea.

You can see example configurations below.

```txt
dns-azure
dns-cloudflare
dns-cloudxns
dns-digitalocean
dns-directadmin
dns-dnsimple
dns-dnsmadeeasy
dns-gehirn
dns-google
dns-hetzner
dns-linode
dns-luadns
dns-njalla
dns-nsone
dns-ovh
dns-rfc2136
dns-route53
dns-sakuracloud
dns-netcup
dns-gandi
dns-transip
dns-inwx
```

In addition add the fields according to the credentials required by your DNS provider:

```yaml
propagation_seconds: 60
azure_config: ''
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
google_domains_access_token: ''
google_domains_zone: ''
hetzner_api_token: ''
gehirn_api_token: ''
gehirn_api_secret: ''
linode_key: ''
linode_version: ''
luadns_email: ''
luadns_token: ''
njalla_token: ''
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
inwx_username: ''
inwx_password: ''
inwx_shared_secret: ''
```

## Example Configurations

These are yaml configurations you would make if editing the `configuration.yaml` file. **You do not need to do this if you are using the Let's Encrypt add-on through the web interface** as it saves the information within the addon itself. If you're reading the information below to get DNS examples, just use the data below the `dns:` line.

For example, **do not use this in the DNS textarea** of the add-on:
```
  dns:
    provider: dns-route53
    aws_access_key_id: 0123456789ABCDEF0123
    aws_secret_access_key: 0123456789abcdef0123456789/abcdef0123456
```
Instead **use this in the DNS text area** of the add-on:
```
    provider: dns-route53
    aws_access_key_id: 0123456789ABCDEF0123
    aws_secret_access_key: 0123456789abcdef0123456789/abcdef0123456
```

Whatever is underneath `dns:` is what you want.

As mentioned, if you are editing the `configuration.yaml` file directly or doing something outside of the add-on web interface itself, you may need the full information below.

<details>
  <summary>HTTP challenge</summary>

  ```yaml
  email: your.email@example.com
  domains:
    - home-assistant.io
  certfile: fullchain.pem
  keyfile: privkey.pem
  challenge: http
  dns: {}
  ```

</details>

<details>
  <summary>DNS challenge</summary>

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

</details>


<details>
  <summary>Azure DNS challenge</summary>

```yaml
email: your.email@example.com
domains:
  - home-assistant.io
certfile: fullchain.pem
keyfile: privkey.pem
challenge: dns
dns:
  provider: dns-azure
  azure_config: azure.txt
```

Please copy your credentials file `azure.txt` into the `share` shared folder on the Home Assistant host before starting the service. One way is to use the "Samba" add on to make the folder available via network or SSH Add-on. You can find information on the required file format in the [documentation] certbot-dns-azure-conf] for the Certbot Azure plugin.

To use this plugin, [create an Azure Active Directory app registration][aad-appreg] and service principal; add a client secret; and create a credentials file using the above directions. Grant the app registration DNS Zone Contributor on the DNS zone to be used for authentication.

[aad-appreg]: https://docs.microsoft.com/en-us/azure/active-directory/develop/howto-create-service-principal-portal#register-an-application-with-azure-ad-and-create-a-service-principal
[certbot-dns-azure-conf]: https://certbot-dns-azure.readthedocs.io/en/latest/#configuration

</details>

<details>
  <summary>Google Cloud DNS challenge</summary>

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
  You can find additional information regarding the required permissions in the "credentials" section here:

  <https://github.com/certbot/certbot/blob/master/certbot-dns-google/certbot_dns_google/__init__.py>

</details>

<details>
  <summary>Google Domains DNS challenge</summary>

  ```yaml
  email: your.email@example.com
  domains:
    - subdomain.home-assistant.io
  certfile: fullchain.pem
  keyfile: privkey.pem
  challenge: dns
  dns:
    provider: dns-google-domains
    google_domains_access_token: XXXX
    google_domains_zone: home-assistant.io
  ```

  To obtain the ACME DNS API token follow the instructions here:

  <https://support.google.com/domains/answer/7630973#acme_dns>

  The optional `google_domains_zone` option specifies the domain name registered with Google Domains.  If not specified, it is guessed based on the public suffix list.

</details>

<details>
  <summary>route53 DNS challenge</summary>

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

</details>

<details>
  <summary>CloudFlare</summary>

Previously, Cloudflare’s "Global API Key" was used for authentication, however this key can access the entire Cloudflare API for all domains in your account, **meaning it could cause *a lot* of damage if leaked**.

  Cloudflare’s newer API Tokens can be restricted to specific domains and operations, and are therefore now the recommended authentication option. The API Token used for Certbot requires only the `Zone:DNS:Edit` permission for the zone in which you want a certificate.

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

</details>

<details>
  <summary>Linode</summary>

  To use this addon with Linode DNS, first [create a new API/access key](https://www.linode.com/docs/platform/api/getting-started-with-the-linode-api#get-an-access-token), with read/write permissions to DNS; no other permissions are needed. Newly keys will likely use API version '4.' **Important**: single quotes are required around the `linode_version` number; failure to do this will cause a type error (as the addon expects a string, not an integer).

  ```yaml
  email: you@mailprovider.com
  domains:
    - ha.yourdomain.com
  certfile: fullchain.pem
  keyfile: privkey.pem
  challenge: dns
  dns:
    provider: dns-linode
    linode_key: 865c9f462c7d54abc1ad2dbf79c938bc5c55575fdaa097ead2178ee68365ab3e
    linode_version: '4'
  ```

</details>

<details>
  <summary>DirectAdmin</summary>

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

</details>

<details>
  <summary>Njalla</summary>

  You need to generate an API token inside Settings > API Access or directly at https://njal.la/settings/api/. If you have a static IP-address restrict the access to your IP. I you are not sure, you probably don't have a static IP-address.

  Example configuration:

  ```yaml
  email: your.email@example.com
  domains:
    - home-assistant.io
  certfile: fullchain.pem
  keyfile: privkey.pem
  challenge: dns
  dns:
    provider: dns-njalla
    njalla_token: 0123456789abcdef0123456789abcdef01234567
  ```

</details>

<details>
  <summary>TransIP</summary>

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

</details>

<details>
  <summary>OVH</summary>

  You will need to generate an OVH API Key first at https://eu.api.ovh.com/createToken/ (for Europe) or https://ca.api.ovh.com/createToken/ (for north America). 

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
  Use `ovh_endpoint: ovh-ca` for north America region.

</details>

<details>
  <summary>RFC2136</summary>

  You will need to set up a server with RFC2136 (Dynamic Update) support with a TKEY (to authenticate the updates).  How to do this will vary depending on the DNS server software in use.  For Bind9, you first need to first generate an authentication key by running
  
  ```
  $ tsig-keygen -a hmac-sha512 letsencrypt
  key "letsencrypt" {
	  algorithm hmac-sha512;
  	secret "G/adDW8hh7FDlZq5ZDW3JjpU/I7DzzU1PDvp26DvPQWMLg/LfM2apEOejbfdp5BXu78v/ruWbFvSK5dwYY7bIw==";
  };
  ```
  
  You don't need to publish this; just copy the key data into your named.conf file:
  ```
  
  key "letsencrypt" {
    algorithm hmac-sha512;
    secret "G/adDW8hh7FDlZq5ZDW3JjpU/I7DzzU1PDvp26DvPQWMLg/LfM2apEOejbfdp5BXu78v/ruWbFvSK5dwYY7bIw==";
  };
  
  ```
  And ensure you have an update policy in place in the zone that uses this key to enable update of the correct domain (which must match the domain in your yaml configuration):
  ```
  
     update-policy {
        grant letsencrypt name _acme-challenge.home-assistant.io. txt;
     };
  ```

  For this provider, you will need to supply all the `rfc2136_*` options. Note that the `rfc2136_port` item is required (there is no default port in the add-on) and, most importantly, the port number must be quoted.  Also, be sure to copy in the key so certbot can authenticate to the DNS server.  Finally, the algorithm should be in all caps.

  An example configuration:

  ```yaml
  email: your.email@example.com
  domains:
    - home-assistant.io
  certfile: fullchain.pem
  keyfile: privkey.pem
  challenge: dns
  dns:
    provider: dns-rfc2136
    rfc2136_server: dns-server.dom.ain
    rfc2136_port: '53'
    rfc2136_name: letsencrypt
    rfc2136_secret: "secret-key"
    rfc2136_algorithm: HMAC-SHA512
  ```
  
</details>

<details>
  <summary>INWX</summary>

  Use the user for the dyndns service, not the normal user.
  The shared secret is the 2FA code, it must be the same length as the example.
  To get this code, you must activate the 2FA or deactivate and reactivate 2FA.
  Without 2FA leave the example key.

  Example configuration:
  ```yaml
  email: your.email@example.com
  domains:
    - your.domain.tld
  certfile: fullchain.pem
  keyfile: privkey.pem
  challenge: dns
  dns:
    provider: dns-inwx
    inwx_username: user
    inwx_password: password
    inwx_shared_secret: ABCDEFGHIJKLMNOPQRSTUVWXYZ012345
  ```

</details>

## Certificate Files

The certificate files will be available within the `/ssl` share after successful request of the certificates. By default other addons are referring to the correct path of the certificates. Note that the `Let's Encrypt` log files may tell you that the certificate files are located under `/data/letsencrypt/live/` but that is NOT true. They are under the `/ssl` directory.

After clicking **Save** on the configuration, go back to the **Info** tab and click **Start**. That will engage Certbot and start requesting the certificate. You can view the status under the **Log** tab.

## Configuration

Once the certificates are created, you will need to adjust the HTTP section of your `configuration.yaml` file. The easiest way to adjust the configuration file is by installing the **Studio Code Server** add-on. Then you can just click the button on the left side of Home Assistant, make your changes, press Ctrl+S, and you're done!

Here is the minimum configuration required in order for SSL certificates to work properly:

```
http:
  ssl_certificate: /ssl/fullchain.pem
  ssl_key: /ssl/privkey.pem
```

You may want to change additional settings, but the two above are required for SSL certificates to work correctly.

[Full HTTP section documentation](https://www.home-assistant.io/integrations/http/)

## Final Steps

Go to **Settings** → **System** → **power button** (top right) → **Restart Home Assistant**.

After a few minutes your system should now be up and you can connect to `https://subdomain.domain.com:8123`.

If you want to confirm that port forwarding is working correctly, use a site like [PortChecker.co](https://portchecker.co/) to confirm connectivity. On your own computer, [pping](https://codingfreaks.de/pping/) is a great little tool that can "ping" a port. It quickly checks for connectivity to a port.

Done!

# Troubleshooting

If PortChecker says your HA port is open, but you cannot connect from within your own network, keep in mind that a lot of basic routers won't let you access your public IP address from within your own local network. For instance, if you've set up port forwarding on your router to send traffic on port 8123 to your Home Assistant at local IP 192.168.1.150, trying to connect to your public IP (say, 1.2.3.4) from another local device (like one at 192.168.1.140) might not work. **This is because most routers only handle port forwarding for incoming traffic from the internet, not from within your home network.**

If you run into this problem, you have a few options:
- Some routers can get around this if you turn on or configure a feature called "hairpin NAT" or "NAT loopback". Look up how to enable that. It basically tells your router to allow accessing your public IP from a private IP address.
- The simplest fix is usually to set up what's called "split DNS". Depending on your DNS setup, this makes it so when you're at home, your subdomain directs to your local IP, but when you're out and about, it'll point to your public IP.
- You can edit your computer's hosts file with the IP and subdomain of HA, but that's not usually the recommended approach. 😊

## Advanced Configuration

<details>
  <summary>Changing the ACME Server</summary>

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

</details>

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
[issue]: https://github.com/home-assistant/addons/issues
[certbot]: https://certbot.eff.org
[reddit]: https://reddit.com/r/homeassistant
