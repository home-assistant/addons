# Home Assistant Add-on: Google Assistant SDK

> [!CAUTION]
> **Deprecation notice**
> The [Google Assistant SDK for device][google-assistant-sdk] Python library
> this add-on depends on is no longer developed and has been archived. The
> OAuth out-of-band (OOB) flow used by the add-on has been deprecated as well.
> Hence a new setup is currently no longer possible.

A virtual personal assistant developed by Google.

![Supports aarch64 Architecture][aarch64-shield] ![Supports amd64 Architecture][amd64-shield] ![Supports armhf Architecture][armhf-shield] ![Supports armv7 Architecture][armv7-shield] ![Supports i386 Architecture][i386-shield]

## About

[Google Assistant][google-assistant] is an AI-powered voice assistant that runs on the Raspberry Pi and x86 platforms and interact via the [DialogFlow][dialogflow-integration] integration with Home-Assistant. You can also use [Google Actions][google-actions] to extend its functionality.

This add-on allows you to access Google Assistant using the microphone and speaker attached to the computer or device running Home Assistant. You can say "Ok Google" followed by your command, and Google Assistant will answer your request.

## ℹ️ Integration your mobile or Google/Nest Home with Home Assistant

If you want to use Google Assistant (for example, from your phone or Google Home device) to interact with your Home Assistant managed devices, then you want the [Google Assistant integration][google-assistant-integration].

[amd64-shield]: https://img.shields.io/badge/amd64-yes-green.svg
[armhf-shield]: https://img.shields.io/badge/armhf-no-red.svg
[armv7-shield]: https://img.shields.io/badge/armv7-yes-green.svg
[dialogflow-integration]: https://www.home-assistant.io/integrations/dialogflow/
[google-actions]: https://actions.google.com/
[google-assistant-integration]: https://www.home-assistant.io/integrations/google_assistant/
[google-assistant]: https://assistant.google.com/
[google-assistant-sdk]: https://github.com/googlesamples/assistant-sdk-python
[i386-shield]: https://img.shields.io/badge/i386-no-red.svg
[aarch64-shield]: https://img.shields.io/badge/aarch64-no-red.svg
