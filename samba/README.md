# Hass.io Core Add-on: Samba share

Share your configuration over the network

![Supports aarch64 Architecture][aarch64-shield] ![Supports amd64 Architecture][amd64-shield] ![Supports armhf Architecture][armhf-shield] ![Supports armv7 Architecture][armv7-shield] ![Supports i386 Architecture][i386-shield]

## About

This Add-on allows you to enable file sharing across different operating systems over a network. 
It lets you acess your config files with Windows and macOS devices.

## Installation

The installation of this add-on is straightforward and easy to do.

1. Navigate in your Home Assistant frontend to **Hass.io** -> **Add-on Store**.
2. Find the "Samba share" add-on and click it.
3. Click on the "INSTALL" button.

## How to use

1. In the configuration section, set a username and password.
2. Save the configuration.
3. Start the add-on.
4. Check the add-on log output to see the result.

## Configuration

Add-on configuration:

```json
{
  "workgroup": "WORKGROUP",
  "username": "Hassio",
  "password": "null",
  "interface": "",
  "allow_hosts": [
    "10.0.0.0/8",
    "172.16.0.0/12",
    "192.168.0.0/16"
  ],
  "veto_files": [
    "._*",
    ".DS_Store",
    "Thumbs.db"
  ]
}
```

### Option: `workgroup` (required)

Change WORKGROUP to reflect your network needs.

### Option: `username` (required)


### Option: `password` (required)


### Option: `interface` (required)
### Option: `allow_hosts` (required)

List of hosts/networks allowed to access your configuration. 

### Option: `veto_files` (optional)

List of files that are neither visible nor accessible. Useful to stop clients from littering the share with temporary hidden files (ex: macOS .DS_Store, Windows Thumbs.db)

## Known issues and limitations


## Support

Got questions?

You have several options to get them answered:

- The [Home Assistant Discord Chat Server][discord].
- The Home Assistant [Community Forum][forum].
- Join the [Reddit subreddit][reddit] in [/r/homeassistant][reddit]

In case you've found an bug, please [open an issue on our GitHub][issue].

[aarch64-shield]: https://img.shields.io/badge/aarch64-yes-green.svg
[amd64-shield]: https://img.shields.io/badge/amd64-yes-green.svg
[armhf-shield]: https://img.shields.io/badge/armhf-yes-green.svg
[armv7-shield]: https://img.shields.io/badge/armv7-yes-green.svg
[discord]: https://discord.gg/c5DvZ4e
[forum]: https://community.home-assistant.io
[i386-shield]: https://img.shields.io/badge/i386-yes-green.svg
[issue]: https://github.com/home-assistant/hassio-addons/issues
[reddit]: https://reddit.com/r/homeassistant
[repository]: https://github.com/hassio-addons/repository
