# Home Assistant Add-on: RPC Shutdown

## Installation

Follow these steps to get the add-on installed on your system:

1. Navigate in your Home Assistant frontend to **Settings** -> **Add-ons** -> **Add-on store**.
2. Find the "RPC Shutdown" add-on and click it.
3. Click on the "INSTALL" button.

## How to use

In the configuration section, define alias, address and credentials and save the configuration.

1. Start the add-on.
2. Check the add-on log output to see the result.

## Configuration

Add-on configuration:

```yaml
computers:
  - alias: test-pc-1
    address: 192.168.0.1
    credentials: user%password
    delay: 0
    message: Home Assistant is shutting down this PC. This cannot be canceled. Please save your work!
  - alias: test-pc-2
    address: 192.168.0.2
    credentials: user%password
    delay: 0
    message: Home Assistant is shutting down this PC. This cannot be canceled. Please save your work!
```

### Option: `computers` (required)

A list of computer objects to be able to shutdown from Home-Assistant.

### Option: `computers.alias` (required)

Set an alias for this record, which becomes the name for the input.

### Option: `computers.address` (required)

IP address or NetBIOS name of the computer to be able to shutdown.

### Option:  `computers.credentials` (required)

Credentials for logging into the computer.
Use a `%` as the delimiter of username and password.

### Option:  `computers.delay` (optional)

A delay (in seconds) before shutting down the computer. This gives a user that happens to be using that computer time to save their work.

### Option:  `computers.message` (optional)

Show a custom message on the screen of the computer that will be shutdown.

## Home Assistant configuration

Use the following inside Home Assistant service call to use it:

```yaml
service: hassio.addon_stdin
data:
  addon: core_rpc_shutdown
  input: test-pc
```

Each line explained:

`service: hassio.addon_stdin`: Use hassio.addon_stdin service to send data over STDIN to an add-on.
`data.addon: core_rpc_shutdown`: Tells the service to send the command to this add-on.
`data.input: test-pc`: Alias name created for the computer in the add-on configuration, and shuts that one down.

## Support

Got questions?

You have several options to get them answered:

- The [Home Assistant Discord Chat Server][discord].
- The Home Assistant [Community Forum][forum].
- Join the [Reddit subreddit][reddit] in [/r/homeassistant][reddit]

In case you've found a bug, please [open an issue on our GitHub][issue].

[forum]: https://community.home-assistant.io
[issue]: https://github.com/home-assistant/addons/issues
[reddit]: https://reddit.com/r/homeassistant
[discord]: https://www.home-assistant.io/join-chat
