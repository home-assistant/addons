# Home Assistant Add-on: Samba share

## Installation

Follow these steps to get the add-on installed on your system:

1. Navigate in your Home Assistant frontend to **Settings** -> **Add-ons** -> **Add-on store**.
2. Find the "Samba share" add-on and click it.
3. Click on the "INSTALL" button.

## How to use

1. In the configuration section, set a username and password.
   You can specify any username and password; these are not related in any way to the login credentials you use to log in to Home Assistant or to log in to the computer with which you will use Samba share.
2. Save the configuration.
3. Start the add-on.
4. Check the add-on log output to see the result.

## Connection

If you are on Windows you use `\\<IP_ADDRESS>\`, if you are on MacOS you use `smb://<IP_ADDRESS>` to connect to the shares.

This addon exposes the following directories over smb (samba):

Directory | Description
-- | --
`addons` | This is for your local add-ons.
`addon_configs` | This is for the configuration files of your add-ons.
`backup` | This is for your backups.
`config` | This is for your Home Assistant configuration.
`media` | This is for local media files.
`share` | This is for your data that is shared between add-ons and Home Assistant.
`ssl` | This is for your SSL certificates.

## Configuration

Add-on configuration:

```yaml
workgroup: WORKGROUP
username: homeassistant
password: YOUR_PASSWORD
allow_hosts:
  - 10.0.0.0/8
  - 172.16.0.0/12
  - 192.168.0.0/16
  - 169.254.0.0/16
  - fe80::/10
  - fc00::/7
veto_files:
  - "._*"
  - ".DS_Store"
  - Thumbs.db
compatibility_mode: false
```

### Option: `workgroup` (required)

Change WORKGROUP to reflect your network needs.

### Option: `username` (required)

The username you would like to use to authenticate with the Samba server.

### Option: `password` (required)

The password that goes with the username configured for authentication.

### Option: `allow_hosts` (required)

List of hosts/networks allowed to access the shared folders.

### Option: `veto_files` (optional)

List of files that are neither visible nor accessible. Useful to stop clients
from littering the share with temporary hidden files
(e.g., macOS `.DS_Store` or Windows `Thumbs.db` files)

### Option: `compatibility_mode`

Setting this option to `true` will enable old legacy Samba protocols
on the Samba add-on. This might solve issues with some clients that cannot
handle the newer protocols, however, it lowers security. Only use this
when you absolutely need it and understand the possible consequences.

Defaults to `false`.

### Option: `enable_addons`

Setting this option to `true` will allow Samba to expose the 'addons' folder,
which is used for installing custom local plugins.

Defaults to `false`.

### Option: `enable_addon_configs`

Setting this option to `true` will allow Samba to expose the 'addon_configs' folder,
which is used for setting configuration of plugins.

defaults to `false`.

### Option: `enable_backups`

Setting this option to `true` will allow Samba to expose the 'backup' folder,
which is where HomeAssistant places its backups.  These backups can contain any information
stored in your configurations for Homeassistant or any add-on, including secrets.

Defaults to `false`.

### Option: `enable_configs`

Setting this option to `true` will allow Samba to expose the 'config' folder,
which is where HomeAssistant stores it core configuration files and databases.  This
includes secrets.

Defaults to `false`.

### Option: `enable_media`

This option will allow Samba to expose the 'media' folder, which is where HomeAssistant
expects you to store any local media files.  This is generally safe to expose.

Defaults to `true`.  If you want to not allow this access, change to `false`.

### Option: `enable_share`

This option will allow Samba to expose the 'share' folder, which is where HomeAssistant
stores information it expects to be shared between different plugins and HomeAssistant.

Defaults to `true`.  If you want to not allow this access, change to `false`.

### Option: `enable_ssl`

Setting this option to `true` will allow Samba to expose the 'ssl' folder,
which is where HomeAssistant stores its public and private SSL keys.  These are considered
sensitive, because anyone who gets ahold of both parts can impersonante your HomeAssistant server,
including using that to collect credentials.

Defaults to `false`.

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
