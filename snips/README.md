# Hass.io Core Add-on: Snips.AI

Support for Snips.ai voice assistant.

![Supports aarch64 Architecture][aarch64-shield] ![Supports amd64 Architecture][amd64-shield] ![Supports armhf Architecture][armhf-shield] ![Supports armv7 Architecture][armv7-shield] ![Supports i386 Architecture][i386-shield]
## About

Snips.ai is an AI-powered voice assistant that runs on the Raspberry Pi 3 and x86 platforms.
In contrast to Google Assistant or Amazon Alexa, it runs on-device and is private by design.

## Installation

The installation of this add-on is straightforward and easy to do.

1. Navigate in your Home Assistant frontend to **Hass.io** -> **Add-on Store**.
2. Find the "Snips.AI" add-on and click it.
3. Click on the "INSTALL" button.

## How to use

Home Assistant comes with certain Intents builtin to handle common tasks. A complete list of Intents can be found in this wiki [Hass Snips Bundle](https://github.com/tschmidty69/hass-snips-bundle-intents/wiki).

The Snips add-on by default comes with an assistant that allows you to turn on lights or switches, open covers, or add and list items to a [Shopping List](/integrations/shopping_list/) if that integration is enabled.

If using a USB microphone and speakers plugged into the Raspberry Pi output, Snips will work without any change to the configuration. Trying saying things like:

```txt
Turn on kitchen light
Open garage door
What is on my shopping list
```

To get started creating your own configuration, follow [their tutorial](https://docs.snips.ai/getting-started/quick-start-console) to create an assistant and download the training data. You can also add the Home Assistant Skill to your assistant to enable the built-in intents, and add or create your own intents to do more complex tasks.

Now install and activate the [Samba](/addons/samba/) add-on so you can upload your training data. Connect to the "share" Samba share and copy your assistant over. Name the file `assistant.zip` or whatever you have configured in the configuration options.

Now it's time to start Snips for the first time. You can configure the microphone and sound card using the Add-on interface. Now start the add-on.

## Configuration

Add-on configuration:

```json
{
  "mqtt_bridge": {
    "active": true,
    "host": "172.17.0.1",
    "port": 1883,
    "user": "",
    "password": ""
  },
  "assistant": "assistant.zip",
  "language": "en",
  "custom_tts": {
      "active": false,
      "platform": "amazon_polly"
  }
}
```

### Option: `assistant`

The name of your custom assistant in `/share`. If no assistant is found, then a default assistant will be used.

### Option: `language`

This is used to select the default custom assistant. Currently, `en`, `de` and `fr` are supported.

### Option group `custom_tts`

Specifies whether a custom tts should be used. And if so,
which custom tts. 

#### Option `custom_tts.active`

Indicates whether a custom tts is used or not.

#### Option: `custom_tts.platform`

Specifies which TTS platform to use.


## Support

Got questions?

You have several options to get them answered:

- The [Home Assistant Discord Chat Server][discord].
- The Home Assistant [Community Forum][forum].
- Join the [Reddit subreddit][reddit] in [/r/homeassistant][reddit]

In case you've found an bug, please [open an issue on our GitHub][issue].

[aarch64-shield]: https://img.shields.io/badge/aarch64-no-red.svg
[amd64-shield]: https://img.shields.io/badge/amd64-yes-green.svg
[armhf-shield]: https://img.shields.io/badge/armhf-yes-green.svg
[armv7-shield]: https://img.shields.io/badge/armv7-no-red.svg
[discord]: https://discord.gg/c5DvZ4e
[forum]: https://community.home-assistant.io
[i386-shield]: https://img.shields.io/badge/i386-no-red.svg
[issue]: https://github.com/home-assistant/hassio-addons/issues
[reddit]: https://reddit.com/r/homeassistant
[repository]: https://github.com/hassio-addons/repository
