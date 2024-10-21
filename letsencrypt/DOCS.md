# Home Assistant Add-on: Letsencrypt

## Installation

Follow these steps to get the add-on installed on your system:

1. Navigate in your Home Assistant frontend to **Settings** -> **Add-ons** -> **Add-on store**.
2. Find the "letsencrypt" add-on and click it.
3. Click on the "INSTALL" button.

## How to use

The Letsencrypt add-on can be configured via the add-on interface.
The configuration via YAML is also possible, see the examples below.

Navigate in your Home Assistant frontend to the add-ons overview page at
**Settings** -> **Add-ons**, and pick the **Let's Encrypt** add-on. On the top,
pick the **Configuration** page.

Provide the domain names to issue certificates for. Additionally, provide the
e-mail address used for the registration, and path values for **Priv Key File**
and **Certificate File**.

There are two options to obtain certificates.

### 1. HTTP challenge

- Requires Port 80 to be available from the internet and your domain assigned to the externally assigned IP address
- Doesn’t allow wildcard certificates (*.yourdomain.com).

### 2. DNS challenge

- Requires you to use one of the supported DNS providers (See "Supported DNS providers" below)
- Allows to request wildcard certificates (*.yourdomain.com)
- Doesn’t need you to open a port to your Home Assistant host on your router.

### DNS providers

<details>
  <summary>Supported DNS providers</summary>

```txt
dns-azure
dns-cloudflare
dns-cloudns
dns-desec
dns-digitalocean
dns-directadmin
dns-dnsimple
dns-dnsmadeeasy
dns-duckdns
dns-dreamhost
dns-dynu
dns-gehirn
dns-godaddy
dns-google
dns-hetzner
dns-infomaniak
dns-ionos
dns-joker
dns-linode
dns-luadns
dns-njalla
dns-noris
dns-simply
dns-nsone
dns-ovh
dns-rfc2136
dns-route53
dns-sakuracloud
dns-namecheap
dns-netcup
dns-gandi
dns-transip
dns-inwx
dns-porkbun
dns-easydns
dns-domainoffensive
dns-websupport
```
</details>

<details>
  <summary>In addition add the fields according to the credentials required by your DNS provider:</summary>

```yaml
propagation_seconds: 60
azure_config: ''
cloudflare_email: ''
cloudflare_api_key: ''
cloudflare_api_token: ''
cloudns_auth_id: ''
cloudns_sub_auth_id: ''
cloudns_sub_auth_user: ''
cloudns_auth_password: ''
desec_token: ''
digitalocean_token: ''
directadmin_url: ''
directadmin_username: ''
directadmin_password: ''
dnsimple_token: ''
dnsmadeeasy_api_key: ''
dnsmadeeasy_secret_key: ''
duckdns_token: ''
dynu_auth_token: ''
google_creds: ''
hetzner_api_token: ''
gehirn_api_token: ''
gehirn_api_secret: ''
godaddy_secret: ''
godaddy_key: ''
infomaniak_api_token: ''
ionos_prefix: ''
ionos_secret: ''
ionos_endpoint: ''
joker_username: ''
joker_password: ''
joker_domain: ''
linode_key: ''
linode_version: ''
luadns_email: ''
luadns_token: ''
njalla_token: ''
noris_token: ''
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
namecheap_username: ''
namecheap_api_key: ''
netcup_customer_id: ''
netcup_api_key: ''
netcup_api_password: ''
gandi_api_key: ''
gandi_token: ''
gandi_sharing_id: ''
transip_username: ''
transip_api_key: ''
inwx_username: ''
inwx_password: ''
inwx_shared_secret: ''
porkbun_key: ''
porkbun_secret: ''
dreamhost_api_baseurl: ''
dreamhost_api_key: ''
domainoffensive_token: ''
plesk_username: ''
plesk_password: ''
plesk_api_url: ''
simply_account_name: ''
simply_api_key: ''
```
</details>

### Configure certificate files

The certificate files will be available within the "ssl" share after successful
request of the certificates.

By default other addons are referring to the correct path of the certificates.
You can in addition find the files via the "samba" addon within the "ssl" share.

For example, to use the certificates provided by this add-on to enable TLS on
Home Assistant in the default paths, add the following lines to Home
Assistant's main configuration file, `configuration.yaml`:

```yaml
# TLS with letsencrypt add-on
http:
  server_port: 443
  ssl_certificate: /ssl/fullchain.pem
  ssl_key: /ssl/privkey.pem
```

### Create & renew certificates

The letsencrypt add-on creates the certificates once it is started: navigate
to **Settings** -> **Add-ons**, pick the **Let's Encrypt** add-on, click the
**START** button on the bottom. The add-on stops once the certificates are
created.

Certificates are not renewed automatically by the plugin. The add-on has to be
started again to renew certificates. If the add-on is started again, it checks
if the certificates are due for renewal. This is usually the case 30 days
before the certificates' due date. If the certificates are not due for renewal,
the add-on terminates without changes. If the certificates are due for renewal,
new certificates will be created.

There are multiple ways how the add-on can be started to check/renew the
certificates. One way to automate the certificate renewal it to configure a
renewal via [Home Assistant automation][haauto], and then restarting this
automation every night via the [Supervisor Addon restart action][supervisorrestart].

[haauto]: https://www.home-assistant.io/docs/automation/editor/
[supervisorrestart]: https://www.home-assistant.io/integrations/hassio/#service-hassioaddon_restart

In this example, the automation will run every day at the chosen time, checking
if a renewal is due, and will request it if needed.

## Advanced

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

<details>
  <summary>Selecting the Key Type</summary>

  By default the ECDSA key type is used. You can choose to use an RSA key for compatibility with systems where ECDSA keys are not supported. ECDSA is widely supported in modern software with security and performance benefits.

  ```yaml
  key_type: 'rsa'
  ```

  When the `key_type` parameter is not set, the add-on will attempt to auto-detect an existing certificate's key type or use `ecdsa` by default.

</details>

<details>
  <summary>Selecting the ECDSA Elliptic Curve</summary>
  
  You can choose from the following ECDSA elliptic curves: `secp256r1`, `secp384r1`

  ```yaml
  key_type: 'ecdsa'
  elliptic_curve: 'secp384r1'
  ```

  When the `elliptic_curve` parameter is not set, ECDSA keys will be generated using the Certbot default. This option must be used with `key_type` set to `'ecdsa'`.

</details>

<details>
  <summary>Set up external account binding</summary>

   The ACME protocol (RFC 8555) defines an external account binding (EAB) field that ACME clients can use to access a specific account on the certificate authority (CA). Some CAs may require the client to utilize the EAB protocol to operate. You can add your EAB key ID and HMAC key through the config options `eab_kid` and `eab_hmac_key`.

  ```yaml
  eab_kid: 'key_id'
  eab_hmac_key: 'AABBCCDD' #Base64url encoded key
  ```

</details>

## Example Configurations

Note: These configuration examples are raw YAML configs. When you use UI edit
mode (default), and configure DNS, simply copy the attributes underneath *dns*
into the *DNS Provider configuration* field.

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
  <summary>RSA key</summary>

  ```yaml
  email: your.email@example.com
  domains:
    - home-assistant.io
  certfile: fullchain.pem
  keyfile: privkey.pem
  key_type: rsa
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

Please copy your credentials file "azure.txt" into the "share" shared folder
on the Home Assistant host before starting the service. One way is to use the
"Samba" add on to make the folder available via network or SSH Add-on. You
can find information on the required file format in the [documentation][certbot-dns-azure-conf]
for the Certbot Azure plugin.

To use this plugin, [create an Azure Active Directory app registration][aad-appreg]
and service principal; add a client secret; and create a credentials file
using the above directions. Grant the app registration DNS Zone Contributor
on the DNS zone to be used for authentication.

[aad-appreg]: https://docs.microsoft.com/en-us/azure/active-directory/develop/howto-create-service-principal-portal#register-an-application-with-azure-ad-and-create-a-service-principal
[certbot-dns-azure-conf]: https://certbot-dns-azure.readthedocs.io/en/latest/#configuration

</details>

<details>
  <summary>GoDaddy DNS challenge</summary>

  ```yaml
  email: your.email@example.com
  domains:
    - subdomain.home-assistant.io
  certfile: fullchain.pem
  keyfile: privkey.pem
  challenge: dns
  dns:
    provider: dns-godaddy
    godaddy_secret: YOUR_GODADDY_SECRET
    godaddy_key: YOUR_GODADDY_KEY
  ```

To obtain the ACME DNS API Key and Secret, follow the instructions here:
<https://developer.godaddy.com/getstarted>

**IMPORTANT**: GoDaddy limits DNS API access to customers with 10 or more domains and/or an active "Discount Domain Club – Premier Membership" plan; the API will respond with a HTTP401 otherwise. See the [Terms of Use](https://developer.godaddy.com/getstarted) for more information.

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
  <summary>Infomaniak DNS challenge</summary>

  ```yaml
  email: your.email@example.com
  domains:
    - subdomain.home-assistant.io
  certfile: fullchain.pem
  keyfile: privkey.pem
  challenge: dns
  dns:
    provider: dns-infomaniak
    infomaniak_api_token: XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
  ```

To obtain the DNS API token follow the instructions here:

<https://manager.infomaniak.com/v3/infomaniak-api>

Choose "Domain" as the scope.

</details>

<details>
  <summary>IONOS DNS challenge</summary>

  ```yaml
  email: your.email@example.com
  domains:
    - subdomain.home-assistant.io
  certfile: fullchain.pem
  keyfile: privkey.pem
  challenge: dns
  dns:
    provider: dns-ionos
    ionos_prefix: YOUR_IONOS_API_KEY_PREFIX
    ionos_secret: YOUR_IONOS_API_KEY_SECRET
    ionos_endpoint: https://api.hosting.ionos.com
  ```

To obtain the DNS API Key Information, follow the instructions here:
<https://developer.hosting.ionos.com/>

</details>


<details>
  <summary>Joker DNS challenge</summary>

  ```yaml
  email: your.email@example.com
  domains:
    - subdomain.example.com
  certfile: fullchain.pem
  keyfile: privkey.pem
  challenge: dns
  dns:
    provider: dns-joker
    joker_username: username
    joker_password: password
    joker_domain: example.com
  ```

You can find further detailed information here:

<https://joker.com/faq/books/jokercom-faq-en/page/lets-encrypt-ssl-certificates>
<https://github.com/dhull/certbot-dns-joker/blob/master/README.md>

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

Previously, Cloudflare’s “Global API Key” was used for authentication, however this key can access the entire Cloudflare API for all domains in your account, meaning it could cause a lot of damage if leaked.

Cloudflare’s newer API Tokens can be restricted to specific domains and operations, and are therefore now the recommended authentication option.
The API Token used for Certbot requires only the `Zone:DNS:Edit` permission for the zone in which you want a certificate.

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
  <summary>Namecheap</summary>

To use this addon with Namecheap, you must first enable API access on your account. See "Enabling API Access" and "Whitelisting IP" [here](https://www.namecheap.com/support/api/intro/) for details and requirements.

Example configuration:

  ```yaml
  email: your.email@example.com
  domains:
    - ha.yourdomain.com
  certfile: fullchain.pem
  keyfile: privkey.pem
  challenge: dns
  dns:
    provider: dns-namecheap
    namecheap_username: your-namecheap-username
    namecheap_api_key: 0123456789abcdef0123456789abcdef01234567
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

<details>
  <summary>Porkbun</summary>

In order to use a domain with this challenge, API access will need enabling on the domain. In order to
do this go to domain management -> select the domain -> details and click the API access toggle.
Then go to the menu in the top right select API access and then create a new api key.
The title does not matter and is not used by certbot, make note of the key and the secret as both are required.

```yaml
email: your.email@example.com
domains:
  - your.domain.tld
certfile: fullchain.pem
keyfile: privkey.pem
challenge: dns
dns:
  provider: dns-porkbun
  porkbun_key: 0123456789abcdef0123456789abcdef01234
  porkbun_secret: 0123456789abcdef0123456789abcdef01234
```
</details>
<details>
  <summary>Dreamhost</summary>

  ```yaml
  email: your.email@example.com
  domains:
    - your.domain.tld
  certfile: fullchain.pem
  keyfile: privkey.pem
  challenge: dns
  dns:
    provider: dns-dreamhost
    dreamhost_baseurl: https://api.dreamhost.com/
    dreamhost_api_key: XXXXXX
  ```
</details>
<details>
  <summary>ClouDNS</summary>
In order to use a domain with this challenge, you first need to log into your control panel and create a 
new HTTP API user from the "API & Resellers" page on top of your control panel.

  ```yaml
  email: your.email@example.com
  domains:
    - your.domain.tld
  certfile: fullchain.pem
  keyfile: privkey.pem
  challenge: dns
  dns:
    provider: dns-cloudns
    cloudns_auth_id: 12345
    cloudns_auth_password: ******
  ```
API Users have full account access.  It is recommended to create an API Sub-user, which can be limited in scope.  You can use either the `sub-auth-id` or the `sub-auth-user` as follows:

  ```yaml
  email: your.email@example.com
  domains:
    - your.domain.tld
  certfile: fullchain.pem
  keyfile: privkey.pem
  challenge: dns
  dns:
    provider: dns-cloudns
    cloudns_sub_auth_id: 12345
    cloudns_auth_password: ******
  ```
  ```yaml
  email: your.email@example.com
  domains:
    - your.domain.tld
  certfile: fullchain.pem
  keyfile: privkey.pem
  challenge: dns
  dns:
    provider: dns-cloudns
    cloudns_sub_auth_user: alice
    cloudns_auth_password: ******
  ```
</details>
<details>
  <summary>Hurricane Electric (HE)</summary>

  ```yaml
  email: your.email@example.com
  domains:
    - your.domain.tld
  certfile: fullchain.pem
  keyfile: privkey.pem
  challenge: dns
  dns:
    provider: dns-he
    he_user: me
    he_pass: ******
  ```
</details>

<details>
  <summary>Netcup</summary>

Both the API password and key can be obtained via the following page: https://www.customercontrolpanel.de/daten_aendern.php?sprung=api
It is important to set the propagation_seconds to >= 630 seconds due to the slow DNS update of Netcup.

  ```yaml
  email: your.email@example.com
  domains:
    - your.domain.tld
  certfile: fullchain.pem
  keyfile: privkey.pem
  challenge: dns
  dns:
    provider: dns-netcup
    netcup_customer_id: "userid"
    netcup_api_key: ****
    netcup_api_password: ****
    propagation_seconds: "900"
  ```
References:
* https://helpcenter.netcup.com/de/wiki/general/unsere-api#authentifizierung
* https://github.com/coldfix/certbot-dns-netcup/issues/28
</details>

<details>
  <summary>easyDNS</summary>

easyDNS REST API access must be requested and granted in order to use this module: https://cp.easydns.com/manage/security/api/signup.php after logging into your account. 

  ```yaml
  email: your.email@example.com
  domains:
    - your.domain.tld
  certfile: fullchain.pem
  keyfile: privkey.pem
  challenge: dns
  dns:
    provider: dns-easydns
    easydns_token: 0123456789abcdef
    easydns_key: ****
    easydns_endpoint: https://rest.easydns.net
  ```
</details>

<details>
  <summary>Dynu</summary>

You can get the API key in the API Credentials area of the Dynu control panel: https://www.dynu.com/ControlPanel/APICredentials

```yaml
email: your.email@example.com
domains:
  - your.domain.tld
certfile: fullchain.pem
keyfile: privkey.pem
challenge: dns
dns:
  provider: dns-dynu
  dynu_auth_token: 0123456789abcdef
```

</details>

<details>

  <summary>WebSupport</summary>

An identifier and secret key have to be obtained to use this module (see https://admin.websupport.sk/sk/auth/apiKey).

  ```yaml
  email: your.email@example.com
  domains:
    - your.domain.tld
  certfile: fullchain.pem
  keyfile: privkey.pem
  challenge: dns
  dns:
    provider: dns-websupport
    websupport_identifier: <identifier>
    websupport_secret_key: <secret_key>
  ```
</details>

<details>
  <summary>domainoffensive</summary>

  ```yaml
  email: your.email@example.com
  domains:
    - your.domain.tld
  certfile: fullchain.pem
  keyfile: privkey.pem
  challenge: dns
  dns:
    provider: dns-domainoffensive
    domainoffensive_token: *****
  ```
</details>


<details>
  <summary>noris network DNS challenge</summary>

  ```yaml
  email: your.email@example.com
  domains:
    - your.domain.tld
  certfile: fullchain.pem
  keyfile: privkey.pem
  challenge: dns
  dns:
    provider: dns-noris
    noris_token: XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
    propagation_seconds: 240
  ```

To obtain the `noris_token` follow the instructions as described in our [GitHub repository][GitHub repo].

You can define the `propagation_seconds` explicitly. Otherwise, it will use the default value (currently set to `60` seconds).

[GitHub repo]: https://github.com/noris-network/certbot-dns-norisnetwork#get-your-api-token

</details>


<details>
  <summary>Plesk Hosting DNS challenge</summary>

  ```yaml
  email: your.email@example.com
  domains:
    - your.domain.tld
  certfile: fullchain.pem
  keyfile: privkey.pem
  challenge: dns
  dns:
    provider: dns-plesk
    plesk_username: your-username
    plesk_password: your-password
    plesk_api_url: https://plesk.example.com
    propagation_seconds: 120
  ```

The `plesk_username` and `plesk_password` are the same as those you use on the login page of your admin panel.

The `plesk_api_url` is the base URL of your Plesk admin panel.

You can define the `propagation_seconds` explicitly. Otherwise, it will use a custom default value (currently set to `120` seconds). If the provided value is less than `120`, then the value is forced to a minimum of `120` seconds.

</details>


<details>
  <summary>Simply.com DNS challenge</summary>

  ```yaml
  email: your.email@example.com
  domains:
    - your.domain.tld
  certfile: fullchain.pem
  keyfile: privkey.pem
  challenge: dns
  dns:
    provider: dns-simply
    simply_account_name: Sxxxxxx
    simply_api_key: YOUR_API_KEY # Replace 'YOUR_API_KEY' with your actual Simply.com API key. 
  ```

The `simply_account_name` refers to the Simply.com account number (Sxxxxxx), and the `simply_api_key` is the account's API key.
The API key assigned to your Simply.com account can be found in your Simply.com Control panel.

</details>


## Certificate files

The certificate files will be available within the "ssl" share after successful request of the certificates.

By default other addons are referring to the correct path of the certificates.
You can in addition find the files via the "samba" addon within the "ssl" share.

## Supported DNS providers

```txt
dns-azure
dns-cloudns
dns-cloudflare
dns-desec
dns-digitalocean
dns-directadmin
dns-dnsimple
dns-dnsmadeeasy
dns-duckdns
dns-dreamhost
dns-dynu
dns-gehirn
dns-google
dns-hetzner
dns-infomaniak
dns-ionos
dns-linode
dns-luadns
dns-njalla
dns-noris
dns-plesk
dns-simply
dns-nsone
dns-ovh
dns-rfc2136
dns-route53
dns-sakuracloud
dns-namecheap
dns-netcup
dns-gandi
dns-transip
dns-inwx
dns-porkbun
dns-easydns
dns-domainoffensive
dns-websupport
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
[issue]: https://github.com/home-assistant/addons/issues
[certbot]: https://certbot.eff.org
[reddit]: https://reddit.com/r/homeassistant
