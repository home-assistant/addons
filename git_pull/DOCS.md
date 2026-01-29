# Home Assistant Add-on: Git pull

## Installation

Follow these steps to get the add-on installed on your system:

1. Navigate in your Home Assistant frontend to **Settings** -> **Add-ons** -> **Add-on store**.
2. Find the "Git pull" add-on and click it.
3. Click on the "INSTALL" button.

## How It Works

The add-on clones your repository to a persistent location (`/data/repo`) and then
syncs the appropriate folder to `/config`. This architecture provides several safety
benefits:

- **Clone failures don't destroy your config**: The repository is cloned to isolated
  storage first, so network or authentication failures won't affect your existing config.
- **Protected files**: Files listed in `sync_exclude` (like `secrets.yaml`) are never
  overwritten during sync.
- **Persistent backups**: Before each sync, your config is backed up to `/data/backups/`
  for manual recovery if needed.
- **Subfolder support**: Use `config_folder` to sync only a specific folder from your
  repository to `/config`.

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

```yaml
git_branch: master
git_command: pull
git_remote: origin
git_prune: 'false'
repository: https://example.com/my_configs.git
auto_restart: false
restart_ignore:
  - ui-lovelace.yaml
  - ".gitignore"
  - exampledirectory/
config_folder: "."
sync_exclude:
  - secrets.yaml
repeat:
  active: false
  interval: 300
deployment_user: ''
deployment_password: ''
deployment_key:
  - "-----BEGIN RSA PRIVATE KEY-----"
  - MIIEowIBAAKCAQEAv3hUrCvqGZKpXQ5ofxTOuH6pYSOZDsCqPqmaGBdUzBFgauQM
  - xDEcoODGHIsWd7t9meAFqUtKXndeiKjfP0MMKsttnDohL1kb9mRvHre4VUqMsT5F
  - "..."
  - i3RUtnIHxGi1NqknIY56Hwa3id2yk7cEzvQGAAko/t6PCbe20AfmSQczs7wDNtBD
  - HgXRyIqIXHYk2+5w+N2eunURIBqCI9uWYK/r81TMR6V84R+XhtvM
  - "-----END RSA PRIVATE KEY-----"
deployment_key_protocol: rsa
```

### Option: `git_remote` (required)

Name of the tracked repository. Leave this as `origin` if you are unsure.

### Option: `git_prune` (required)

`true`/`false`: If set to true, the add-on will clean-up branches that are deleted on the remote repository, but still have cached entries on the local machine. Leave this as `false` if you are unsure.

### Option: `git_branch` (required)

Branch name of the Git repo. If left empty, the currently checked out branch will be updated. Leave this as 'master' if you are unsure.

### Option: `git_command` (required)

`pull`/`reset`: Command to run. Leave this as `pull` if you are unsure.

- `pull`
  
  - Incorporates changes from a remote repository into the current branch. Will preserve any local changes to tracked files.

- `reset`
  
  - Will execute `git reset --hard` and overwrite any local changes to tracked files and update from the remote repository. **Warning**: Using `reset` WILL overwrite changes to tracked files. You can list all tracked files with this command: `git ls-tree -r master --name-only`.

### Option: `repository` (required)

Git URL to your repository (make sure to use double quotes).

### Option: `auto_restart` (required)

`true`/`false`: Restart Home Assistant when the configuration has changed (and is valid).

### Option: `restart_ignore` (optional)

When `auto_restart` is enabled, changes to these files will not make HA restart. Full directories to ignore can be specified.

### Option: `config_folder` (optional)

The folder within your repository that contains the Home Assistant configuration files. This folder will be synced to `/config`. Default is `.` (repository root).

Example use cases:
- Your HA config is in a `homeassistant/` subfolder: set `config_folder: homeassistant`
- Your repo has multiple configs for different environments: set `config_folder: production`

### Option: `sync_exclude` (optional)

List of files and folders that should never be overwritten when syncing from the repository. Default is `["secrets.yaml"]`.

This is useful for:
- Protecting `secrets.yaml` from being overwritten (default behavior)
- Protecting local-only configuration files
- Excluding the `.storage/` directory if you don't want to sync Home Assistant's internal state

Example:
```yaml
sync_exclude:
  - secrets.yaml
  - .storage/
  - local_config.yaml
```

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

[discord]: https://discord.gg/c5DvZ4e
[forum]: https://community.home-assistant.io
[issue]: https://github.com/home-assistant/addons/issues
[reddit]: https://reddit.com/r/homeassistant
[repository]: https://github.com/hassio-addons/repository
