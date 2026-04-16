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
the ESPHome integration in Home Assistant. If auto discovery doesn't work, click the
following button:

[![Open your Home Assistant instance and start setting up a new integration.](https://my.home-assistant.io/badges/config_flow_start.svg)](https://my.home-assistant.io/redirect/config_flow_start/?domain=esphome)

Then, enter the device IP address `127.0.0.1` with port 6053.

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

### Option `stop_word`

ID of the stop word model (default: `stop`).

### Option: `refractory_seconds`

Minimum seconds between wake word activations to prevent double-triggers
(default: `2.0`).

### Option `wakeup_sound`

Sound file played when wake word is detected (default: `sounds/wake_word_triggered.flac`).

### Option: `enable_thinking_sound`

Play a short sound while the assistant processes a request (default: `false`).
Can be toggled at runtime from the Home Assistant device page.

### Option `processing_sound`

Sound played while assistant is processing (default: `sounds/processing.wav`).

### Option `timer_sound`

Sound file played when timer finishes (default: `sounds/timer_finished.flac`).

### Option: `timer_max_ring_seconds`

Seconds after which the timer stops ringing (default: `900` which is 15 minutes).

### Option `mic_volume`

Control microphone volume by fixed value (default: `1.0` which is the maximum)

### Option `mic_noise_suppression`

Microphone noise suppression level (0 is disabled, 4 is max). Disabled by default.

### Option: `mic_auto_gain`

Automatic volume boost for microphone (0 is disabled, 31 dbfs is max). Disabled by default.

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
