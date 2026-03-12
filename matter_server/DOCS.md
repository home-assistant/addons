# Home Assistant App: Matter Server

## Installation

Use the following steps to install this app.

1. Click the Home Assistant My button below to open the app page on your
   Home Assistant instance.

   [![Open this app in your Home Assistant instance.][addon-badge]][addon]

1. Click the "Install" button to install the app.

## How to use

Start the Matter Server app to make the WebSocket available to Home
Assistant Core. Install the [Matter integration][matter_integration]
in Home Assistant Core.

### Access WebSocket interface externally (advanced)

By default, the OHF Matter Server's WebSocket interface is only exposed
internally. It is still possible to enable access through the host interface.
To do so, click on "Show disabled ports" and enter a port (e.g. 5580) in the
Matter Server WebSocket server port field.

## Server variants

This app runs the Python Matter Server implementation from the
[home-assistant-libs/python-matter-server][matter_server_repo] repository by default.

Starting with version 8.2.0 and choosing the "Beta" flag (see below) the new OHF
Matter(.js) Server is executed instead of the Python Matter Server.

## Configuration

App configuration:

| Configuration        | Description                                                                                             |
|----------------------|---------------------------------------------------------------------------------------------------------|
| log_level            | Logging level of the Matter Server component.                                                           |
| log_level_sdk        | Logging level for Matter SDK logs (Python only).                                                        |
| beta                 | Whether to install the latest beta version on startup (runs matter.js-based Matter Server starting with 8.2.0) |
| enable_test_net_dcl  | Enable test-net DCL for PAA root certificates, OTA updates and other device information.                |
| bluetooth_adapter_id | Set BlueZ Bluetooth Controller ID (for local commissioning)                                             |
| matter_server_env_vars | Extra environment variables exported before start (only relevant for the JavaScript Matter Server / Beta mode). Use `KEY=VALUE` entries. |
| matter_server_version | Custom Matter Server version. In JavaScript/Beta mode, only `0.x.y` or `1.x.y` values are used; other values are ignored and latest is installed. |

### `matter_server_env_vars` (JavaScript server only)

This option is only relevant when the **Beta** flag is enabled (JavaScript
Matter Server).

```yaml
matter_server_env_vars:
  - NODE_OPTIONS=--max-old-space-size=512
  - MY_FLAG=true
```

### `matter_server_version`

- Python mode: installs the configured `python-matter-server` version.
- JavaScript/Beta mode: uses the configured version only if it matches
  `0.x.y` or `1.x.y` (for example `1.2.3`); all other values are ignored and
  `latest` is installed.

## Support

Got questions?

You have several options to get them answered:

- The [Home Assistant Discord Chat Server][discord].
- The Home Assistant [Community Forum][forum].
- Join the [Reddit subreddit][reddit] in [/r/homeassistant][reddit]

In case you've found a bug, please [open an issue on our GitHub][issue].

[addon]: https://my.home-assistant.io/redirect/supervisor_addon/?addon=core_matter_server
[addon-badge]: https://my.home-assistant.io/badges/supervisor_addon.svg
[discord]: https://discord.gg/c5DvZ4e
[forum]: https://community.home-assistant.io
[reddit]: https://reddit.com/r/homeassistant
[issue]: https://github.com/home-assistant/addons/issues
[matter_server_repo]: https://github.com/home-assistant-libs/python-matter-server
[matter_integration]: https://www.home-assistant.io/integrations/matter/
