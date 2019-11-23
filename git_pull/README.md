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
accessed your git repository. Examples of logs you might see if
there were no errors are: `[Info] Nothing has changed.`,
`[Info] Something has changed, checking Home-Assistant config...`,
or `[Info] Local configuration has changed. Restart required.`.

If you made it this far, you might want to let the add-on automatically
check for updates by setting the `active` field (a subfield of `repeat`)
to `true` and turning on "Start on boot."

## Configuration

Add-on configuration:

```json
{
  "git_branch": "master",
  "git_command": "pull",
  "git_remote": "origin",
  "git_prune": "false",
  "git_config_directory": "/",
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

### Option: `git_remote` (required)

Name of the tracked repository. Leave this as `origin` if you are unsure.

### Option: `git_prune` (required)

`true`/`false`: If set to true, the add-on will clean-up branches that are deleted on the remote repository, but still have cached entries on the local machine. Leave this as `false` if you are unsure.

### Option `git_config_dir` (required)

Name of the directory in your git repository to copy to your "/config" directory. Defaults to `/` (the root of your repository)

### Option: `git_branch` (required)

Branch name of the Git repo. If left empty, the currently checked out branch will be updated. Leave this as 'master' if you are unsure.

### Option: `git_command` (required)

`pull`/`reset`: Command to run. Leave this as `pull` if you are unsure.

- `pull`
  
  - Incorporates changes from a remote repository into the current branch. Will preserve any local changes to tracked files.

- `reset`
  
  - Will execute `git reset --hard` and overwrite any local changes to tracked files and update from the remote repository. **Warning**: Using `reset` WILL overwrite changes to tracked files. You can list all tracked files with this command: `git ls-tree -r master --name-only`.

### Option: `repository` (required)

Git URL to your repository (make sure to use double quotes). You have to add `.git` to your repository URL (see example configuration).

### Option: `auto_restart` (required)

`true`/`false`: Restart Home Assistant when the configuration has changed (and is valid).

### Option: `restart_ignore` (optional)

When `auto_restart` is enabled, changes to these files will not make HA restart. Full directories to ignore can be specified.

### Option group: `repeat`

The following options are for the option group: `repeat` and configure the Git pull add-on to poll the repository for updates periodically automatically.

#### Option: `repeat.active` (required)

`true`/`false`: Enable/disable automatic polling.

#### Option: `repeat.interval` (required)

The interval in seconds to poll the repo for if automatic polling is enabled.

### Option: `deployment_user` (optional)

Username to use when authenticating to a repository with a username and password.

### Option: `deployment_password` (optional)

Password to use when authenticating to a repository.  Ignored if `deployment_user` is not set.

### Option: `deployment_key` (optional)

A private SSH key that will be used for communication during Git operations. This key is mandatory for ssh-accessed repositories, which are the ones with the following pattern: `<user>@<host>:<repository path>`. This key has to be created without a passphrase.

### Option: `deployment_key_protocol` (optional)

The key protocol. Default is `rsa`. Valid protocols are:
  - dsa
  - ecdsa
  - ed25519
  - rsa

The protocol is typically known by the suffix of the private key --e.g., a key file named `id_rsa` will be a private key using `rsa` protocol.

## Support

Got questions?

You have several options to get them answered:

- The [Home Assistant Discord Chat Server][discord].
- The Home Assistant [Community Forum][forum].
- Join the [Reddit subreddit][reddit] in [/r/homeassistant][reddit]

In case you've found a bug, please [open an issue on our GitHub][issue].

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
