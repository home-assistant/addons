# Changelog

## 5.2.2

- Add IONOS DNS support

## 5.2.1

- Revert Cryptography to 42.0.8 to avoid deprecation warnings

## 5.2.0

- Update Certbot/ACME to 2.11.0 & update all plugins to their latest version
- Update to Python 3.12
- Update to Alpine 3.20

## 5.1.4

- Drop Google Domains support (the new operator Squarespace has no ACME support)

## 5.1.3

- Add godaddy.com DNS support

## 5.1.2

- Fixes subdomain DNS challenge not working for Simply.com

## 5.1.1

- Add Simply.com DNS support

## 5.1.0

- Add external account binding support

## 5.0.27

- Add Plesk DNS challenge support

## 5.0.26

- Add noris network DNS challenge support

## 5.0.25

- Add DigitalOcean propagation-seconds support

## 5.0.24

- Fix Gandi DNS support using API key

## 5.0.23

- Fix missing domain configuration for joker.com DNS challenge

## 5.0.22

- Add joker.com DNS challenge support

## 5.0.21

- Fix configuration to make list of provider parsable again

## 5.0.20

- Fix file-structure.sh script
- Fix domainoffensive plug-in installation

## 5.0.19

- Add domainoffensive challenge support

## 5.0.18

- Fix Gandi DNS support using API key
- Add Gandi DNS support using token authentication

## 5.0.17

- Add WebSupport challenge support

## 5.0.16

- Add Dynu challenge support

## 5.0.15

- Add easyDNS challenge support

## 5.0.14

- Update docs for key_type setting

## 5.0.13

- By default, choose key type based on existing certificates at startup.
- Allow ECDSA curve selection.

## 5.0.12

- Fix ClouDNS challenge support

## 5.0.11

- Add HE DNS challenge support

## 5.0.10

- Add ClouDNS DNS challenge support

## 5.0.9

- Add option to specify Private Key type

## 5.0.8

- Add Dreamhost DNS challenge support

## 5.0.7

- Add Porkbun DNS challenge support

## 5.0.6

- Add Infomaniak DNS challenge support

## 5.0.5

- Fix DirectAdmin DNS challenge support

## 5.0.4

- Add Namecheap DNS challenge support

## 5.0.3

- Add deSEC DNS challenge support

## 5.0.2

- Fix DirectAdmin DNS challenge support

## 5.0.1

- Add DuckDNS DNS challenge support

## 5.0.0

- Upgrade to Certbot 2.7.4 & all DNS authenticator plug-ins
- Drop CloudXNS (removed in Certbot upstream)
- Update to Python 3.11
- Update to Alpine 3.18
- Add GANDI DNS propagation delay setting

## 4.12.9

- Add Google Domains DNS challenge support

## 4.12.8

- Add INWX DNS challenge support

## 4.12.7

- Add Hetzner DNS challenge support

## 4.12.6

- Add Azure DNS challenge support

## 4.12.5

- Fix another syntax error in runs script for rfc2136

## 4.12.4

- Fix syntax error in runs script for rfc2136
- Fix finish script for S6 V3

## 4.12.3

- Fix the DNS propagation delay setting for the rfc2136 provider

## 4.12.2

- Use HA wheels when possible during build

## 4.12.1

- Set preferred chain to "ISRG Root X1"

## 4.12.0

- Update Certbot 1.21.0 & Plugins
- Update to Python 3.9
- Update to Alpine 3.14

## 4.11.0

- Add support for Njalla DNS

## 4.10.0

- Add support for custom ACME server and Certificate Authority

## 4.9.0

- Add support for DirectAdmin DNS

## 4.8.0

- Add support for Gandi DNS

## 4.7.1

- Adjust init settings

## 4.7.0

- Fix issue with DNS challenge
- Convert to s6-overlay

## 4.6.0

- Streamline propagation seconds
- Add propagation seconds to CloudFlare / option selection

## 4.5.0

- Update cerbot to 1.2.0
- Update image to Alpine 3.11
- Support CloudFlare API Token

## 4.4.0

- Added support for nectup dns

## 4.3.0

- Added support for google dns
- Fixed AWS support
- Updated documentation
- Update cerbot to 1.0.0

## 4.2.0

- Bugfix default empty dns setting

## 4.1.0

- Pin image to Alpine3.10
- Bugfix default options with empty dns

## 4.0.0

- Added support for dns challenges
