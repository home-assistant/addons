# Hass.io Core Add-on: Git pull

Load and update configuration files for Home Assistant from a Git repository.

![Supports aarch64 Architecture][aarch64-shield] ![Supports amd64 Architecture][amd64-shield] ![Supports armhf Architecture][armhf-shield] ![Supports armv7 Architecture][armv7-shield] ![Supports i386 Architecture][i386-shield]

## About

You can use this add-on to `git pull` updates to your Home Assistant configuration files from a Git
repository.

## Installation

The installation of this add-on is straightforward and easy to do.

1. Navigate in your Home Assistant frontend to **Hass.io** -> **Add-on Store**.
2. Find the "Git pull" add-on and click it.
3. Click on the "INSTALL" button.

## How to use

In the configuration section, set the repository field to your repository's
clone URL and check if any other fields need to be customized to work with
your repository. Next,

1. Start the add-on.
2. Check the add-on log output to see the result.

If the log doesn't end with an error, the add-on has successfully
accessed your git repository. Examples of logs you will see if
there were no errors are: `[Info] Nothing has changed.` or
`[Info] Something has changed, checking Home-Assistant config...`

If you made it this far you may want to let the add-on automatically
check for updates at regular intervals by setting the `active` field (a
subfield of `repeat`) to `true` and turning on "Start on boot."

## Configuration

Add-on configuration:

```json
{
  "git_branch": "master",
  "git_command": "pull",
  "git_remote": "origin",
  "git_prune": "false",
  "repository": "https://example.com/my_configs.git",
  "auto_restart": false,
  "restart_ignore": [
    "ui-lovelace.yaml",
    ".gitignore",
    "exampledirectory/"
  ],
  "repeat": {
    "active": false,
    "interval": 300
  },
  "deployment_user": "",
  "deployment_password": "",
  "deployment_key": [
"-----BEGIN RSA PRIVATE KEY-----",
"MIIEowIBAAKCAQEAv3hUrCvqGZKpXQ5ofxTOuH6pYSOZDsCqPqmaGBdUzBFgauQM",
"xDEcoODGHIsWd7t9meAFqUtKXndeiKjfP0MMKsttnDohL1kb9mRvHre4VUqMsT5F",
"...",
"i3RUtnIHxGi1NqknIY56Hwa3id2yk7cEzvQGAAko/t6PCbe20AfmSQczs7wDNtBD",
"HgXRyIqIXHYk2+5w+N2eunURIBqCI9uWYK/r81TMR6V84R+XhtvM",
"-----END RSA PRIVATE KEY-----"
  ],
  "deployment_key_protocol": "rsa"
}
```

### Option: `version` (required)

The version of Home Assistant that want to check your configuration against.

Setting this option to `latest` will result in checking your configuration
against the latest stable release of Home Assistant.

## Known issues and limitations

- Currently, this add-on only support checking against Home Assistant >= 0.94
  or less 0.91.

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
