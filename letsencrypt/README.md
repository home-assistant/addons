# Let's Encrypt
Manage let's encrypt certificate for HomeAssistant and HassIO addons.

First run generate certificates and next run of addon will renew it. You can automate the renew with HomeAssistant automation and call hassio.addon_start.

## Options

- `email`: your email address for register
- `domains`: a list with domains
