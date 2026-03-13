# Home Assistant App: Samba share

## Installation

Follow these steps to get the app (formerly known as add-on) installed on your system:

1. In Home Assistant, go to **Settings** > **Apps** > **Install app**.
2. Find the "Samba share" app and click it.
3. Click on the "INSTALL" button.

[![Open your Home Assistant instance and show the dashboard of an app.](https://my.home-assistant.io/badges/supervisor_addon.svg)](https://my.home-assistant.io/redirect/supervisor_addon/?addon=core_samba)

## How to use

1. In the configuration section, set a username and password.
   You can specify any username and password; these are not related in any way to the login credentials you use to log in to Home Assistant or to log in to the computer with which you will use Samba share.
2. Review the enabled shares. Disable any you do not plan to use. Shares can be re-enabled later if needed.

## Connection

If you are on Windows you use `\\<IP_ADDRESS>\`, if you are on MacOS you use `smb://<IP_ADDRESS>` to connect to the shares.

This app exposes the following directories over smb (samba):

Directory | Description
-- | --
`addons` | This is for your local apps.
`addon_configs` | This is for the configuration files of your apps.
`backup` | This is for your backups.
`config` | This is for your Home Assistant configuration.
`media` | This is for local media files.
`share` | This is for your data that is shared between apps and Home Assistant.
`ssl` | This is for your SSL certificates.

## Configuration

App configuration:

```yaml
  username: homeassistant
  password: null
  workgroup: WORKGROUP
  enabled_shares:
    - addons
    - addon_configs
    - backup
    - config
    - media
    - share
    - ssl
  local_master: true
  compatibility_mode: false
  apple_compatibility_mode: true
  server_signing: "default"
  netbios: true
  veto_files:
    - ._*
    - .DS_Store
    - Thumbs.db
    - icon?
    - .Trashes
  allow_hosts:
    - 10.0.0.0/8
    - 172.16.0.0/12
    - 192.168.0.0/16
    - 169.254.0.0/16
    - fe80::/10
    - fc00::/7
```




### Option: `username` (required)

The username you would like to use to authenticate with the Samba server.

### Option: `password` (required)

The password that goes with the username configured for authentication.

### Option: `workgroup` (required)

Change WORKGROUP to reflect your network needs.

### Option: `enabled_shares` (required)

List of Samba shares that will be accessible. Any shares removed or commented out of the list will not be accessible.

### Option: `local_master` (required)

Enable to try and become a local master browser on a subnet.

### Option: `compatibility_mode`

Setting this option to `true` will enable old legacy Samba protocols
on the Samba app. This might solve issues with some clients that cannot
handle the newer protocols, however, it lowers security. Only use this
when you absolutely need it and understand the possible consequences.

Defaults to `false`.

### Option: `apple_compatibility_mode`

Enable Samba configurations to improve interoperability with Apple devices.
This can cause issues with file systems that do not support xattr such as exFAT.

Defaults to `true`.

### Option: `server_signing`

Configure the SMB server signing requirement. This option can improve security by requiring message signing, which helps prevent man-in-the-middle attacks.
Refer to the man page for smb.conf for detailed information about the values: **default**, **auto**, **mandatory**, and **disabled**.

Defaults to `default`.

### Option: `netbios`

NetBIOS is a legacy network protocol for accessing SMB/CIFS shares.
Enable for legacy clients older than Windows Vista (Windows 95/98/ME, Windows NT, Windows 2000, Windows XP and LanManager), or OS X 10.9 (Mavericks). This setting is enabled by default for compatibility; disable it on modern installations.

Defaults to `true`.

### Option: `veto_files` (optional)

List of files that are neither visible nor accessible. Useful to stop clients
from littering the share with temporary hidden files
(e.g., macOS `.DS_Store` or Windows `Thumbs.db` files)

### Option: `allow_hosts` (required)

List of hosts/networks allowed to access the shared folders.

## Network ports

From version 12.6.1 of this app, it is possible to override the default ports in the app configuration.  Only very specific use cases should do this.
If ports have been changed, due to known constraints with macOS Finder, it is **not** possible to access the share from Finder's Network location browser.  You _can_ access the share by opening the **Connect to server...** dialog (⌘ + K).
```URL
smb://<hostname>:<port>/<sharename>
```

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
