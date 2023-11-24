# Home Assistant Add-on: File editor

## Installation

Follow these steps to get the add-on installed on your system:

1. Navigate in your Home Assistant frontend to **Settings** -> **Add-ons** -> **Add-on store**.
2. Find the "File editor" add-on and click it.
3. Click on the "INSTALL" button.

## How to use

In general, this add-on requires no configuration from your end.

1. Toggle the "Show in sidebar" option, which adds the File editor to the main menu.
2. Start the add-on.
3. Refresh your browser, the "File editor" is now visible in the sidebar.
4. Click on the "File editor" menu option and start configuring!

## Configuration

Add-on configuration:

```yaml
dirsfirst: false
enforce_basepath: false
git: true
ignore_pattern:
  - __pycache__
ssh_keys: []
```

### Option: `dirsfirst` (required)

This option allows you to list directories before files in the file browser tree.

Set it to `true` to list directories first, `false` otherwise.

### Option: `enforce_basepath` (required)

If set to `true`, access is limited to files within the `/homeassistant` directory
(also known as the `/config` folder inside Home Assisant itself).

### Option: `git` (required)

If set to `true`, add-on will initialize git for directories which support it.

### Option: `ignore_pattern` (required)

This option allows you to hide files and folders from the file browser tree.
By default, it hides the `__pycache__` folders.

### Option: `ssh_keys` (required)

A list of filenames containing SSH private keys. These can be used to allow for access to remote git repositories.

## Known issues and limitations

- This add-on can only be used via Ingress and has no direct access.

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
