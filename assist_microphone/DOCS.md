# Assist Microphone

Use [Assist](https://www.home-assistant.io/voice_control/) voice assistant with a USB microphone. For example, a USB webcam.

## How to use

After this add-on is installed and running, it will be automatically discovered
by the Wyoming integration in Home Assistant. To finish the setup,
click the following my button:

[![Open your Home Assistant instance and start setting up a new integration.](https://my.home-assistant.io/badges/config_flow_start.svg)](https://my.home-assistant.io/redirect/config_flow_start/?domain=wyoming)

Alternatively, you can install the Wyoming integration manually, see the
[Wyoming integration documentation](https://www.home-assistant.io/integrations/wyoming/)
for more information.

## Configuration

### Option: `awake_wav`

Path to WAV file to play when wake word is detected (empty to disable, default is `/usr/src/sounds/awake.wav`).

### Option: `done_wav`

Path to WAV file to play when voice command is finished (empty to disable, default is `/usr/src/sounds/done.wav`).

### Option: `timer_finished_wav`

Path to WAV file to play when timer is finished (empty to disable, default is `/usr/src/sounds/timer_finished.wav`).

### Option: `timer_repeat_count`

Number of times to repeat `timer_finished_wav` (default is 3).

### Option: `timer_repeat_delay`

Delay before repeating `timer_finished_wav`, in seconds (default is 0.75).

### Option: `noise_suppression`

Noise suppression level (0 is disabled, 4 is max). Disabled by default.

### Option: `auto_gain`

Automatic volume boost for microphone (0 is disabled, 31 dbfs is max). Disabled by default.

### Option: `mic_volume_multiplier`

Multiply microphone volume by fixed value (1.0 = no change, 2.0 = twice as loud). 1.0 is the default.

### Option: `sound_enabled`

Enables or disables output audio.

### Option: `sound_volume_multiplier`

Multiply sound output volume by fixed value (1.0 = no change, 2.0 = twice as loud). 1.0 is the default.

### Option: `synthesize_using_webhook`

Send text-to-speech text to a Home Assistant webhook for further processing. You can achieve this by using the webhook platform as a trigger inside an automation for example. 

<details>
<summary>Example Automation</summary>

```yaml
alias: Satellite response
description: ""
trigger:
  - platform: webhook
    allowed_methods:
      - POST
      - PUT
    local_only: true
    webhook_id: "synthesize-assist-microphone-response" # This must match the webhook_id in the add-on configuration
condition: []
action:
  - service: telegram_bot.send_message
    metadata: {}
    data:
      message: "{{ trigger.json.response }}" # This is how you catch whatever the add-on sent
      title: Mycroft said
  - service: tts.cloud_say
    data:
      entity_id: media_player.name # Don't forget to change this to your own media player
      cache: false
      message: "{{ trigger.json.response }}" # This is how you catch whatever the add-on sent
mode: single
```
</details>

Read the HA webhook automation trigger [documentation](https://www.home-assistant.io/docs/automation/trigger/#webhook-trigger) for more information. 

If you're using this feature, you will need to set `sound_enabled` to _true_ as well or nothing will happen.

### Option: `webhook_id`

The name of the webhook to use. This is only relevant if `synthesize_using_webhook` is _true_.

### Option: `synthesize_script`

The script that does the heavy lifting of sending the text you want to synthesize to the home assistant webhook. This is only relevant if `synthesize_using_webhook` is _true_.

### Option: `debug_logging`

Enable debug logging.

## Support

Got questions?

You have several options to get them answered:

- The [Home Assistant Discord Chat Server][discord].
- The Home Assistant [Community Forum][forum].
- Join the [Reddit subreddit][reddit] in [/r/homeassistant][reddit]

In case you've found an bug, please [open an issue on our GitHub][issue].

[discord]: https://discord.gg/c5DvZ4e
[forum]: https://community.home-assistant.io
[issue]: https://github.com/home-assistant/addons/issues
[reddit]: https://reddit.com/r/homeassistant
[repository]: https://github.com/hassio-addons/repository
