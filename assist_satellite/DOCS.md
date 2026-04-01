# Assist Satellite

Use [Assist](https://www.home-assistant.io/voice_control/) voice assistant with
a local USB microphone for STT commands and a speaker for audio playback. This app uses the [ESPHome](https://esphome.io/) satellite protocol based on [Linux Voice Assistant](https://github.com/OHF-Voice/linux-voice-assistant) and is automatically discovered by Home Assistant via the ESPHome integration.

> [!NOTE]
> **Running Home Assistant OS in a virtual machine?**
> The microphone and speaker must be passed through from the host to the VM
> before this app can use them. How to do this depends on your hypervisor —
> consult its documentation for USB or audio device passthrough.

## How to use

After this app is installed and running it will be automatically discovered by
the ESPHome integration in Home Assistant. To finish the setup, click the
following button:

[![Open your Home Assistant instance and start setting up a new integration.](https://my.home-assistant.io/badges/config_flow_start.svg)](https://my.home-assistant.io/redirect/config_flow_start/?domain=esphome)

Once connected, the satellite exposes the following controls on its Home
Assistant device page:

- **Media Player** — volume control and media playback
- **Mute switch** — disable/enable wake word detection at runtime
- **Thinking Sound switch** — toggle the processing sound that plays while the assistant thinks

## Configuration

### Option: `name`

Friendly name shown in Home Assistant. Leave empty to auto-generate from MAC address.

### Option: `port`

TCP port the ESPHome satellite server listens on (default: `6053`). Only change
this if you run multiple satellites on the same host.

### Option: `audio_input_device`

Soundcard name or index for microphone input. Leave empty to use the system
default. Enable `debug_logging` to list available devices in the log.

### Option: `audio_output_device`

mpv audio device name for sound output. Leave empty to use the system default.
Enable `debug_logging` to list available devices in the log.

### Option: `wake_word`

ID of the wake word model (default: `okay_nabu`). Can also be changed at
runtime from Home Assistant voice assistant settings.

### Option: `refractory_seconds`

Minimum seconds between wake word activations to prevent double-triggers
(default: `2.0`).

### Option: `thinking_sound`

Play a short sound while the assistant processes a request (default: `false`).
Can be toggled at runtime from the Home Assistant device page.

### Option: `debug_logging`

Enable verbose debug logging.

## Support

Got questions?

You have several options to get them answered:

- The [Home Assistant Discord Chat Server][discord].
- The Home Assistant [Community Forum][forum].
- Join the [Reddit subreddit][reddit] in [/r/homeassistant][reddit]

In case you've found an bug, please [open an issue on our GitHub][issue].

[discord]: https://www.home-assistant.io/join-chat
[forum]: https://community.home-assistant.io
[issue]: https://github.com/home-assistant/addons/issues
[reddit]: https://reddit.com/r/homeassistant
[repository]: https://github.com/hassio-addons/repository
