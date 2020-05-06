# Home Assistant Add-on: Google Assistant SDK

A virtual personal assistant developed by Google.

![Supports aarch64 Architecture][aarch64-shield] ![Supports amd64 Architecture][amd64-shield] ![Supports armhf Architecture][armhf-shield] ![Supports armv7 Architecture][armv7-shield] ![Supports i386 Architecture][i386-shield]

## About

[Google Assistant][google-assistant] is an AI-powered voice assistant that runs on the Raspberry Pi and x86 platforms and interact via the [DialogFlow][dialogflow-integration] integration with Home-Assistant. You can also use [Google Actions][google-actions] to extend its functionality.

You can simply say "Ok Google" following by your command, and Google Assistant will answer your request.

## ℹ️ Integration your mobile or Google/Nest Home with Home Assistant

If you want to integrate your Google Home or mobile phone running Google Assistant, with Home Assistant, then you want the [Google Assistant integration][google-assistant-integration].

## Installation

Follow these steps to get the add-on installed on your system:

1. Navigate in your Home Assistant frontend to **Supervisor** -> **Add-on Store**.
2. Find the "Google Assistant SDK" add-on and click it.
3. Click on the "INSTALL" button.

## How to use

[Click here for the full documentation](DOC.md)

## Configuration

Add-on configuration:

```yaml
client_secrets: google_assistant.json
project_id: project_id_from_google
model_id: model_id_from_google
```

### Option: `clients_secrets` (required)

The name of the client secrets file to you've downloaded from Google and placed in your `/share` folder.

### Option: `project_id` (required)

Project ID of the project you've created at Google for this add-on.
The project id can be found in your `google_assistant.json` file, or under project settings in the [Google Actions Console][google-actions-console].

### Option: `model_id` (required)

The ID of the model you've registered at Google for this add-on.

The model id can also be found under the "Develop - Device registration" tab in the [Google Actions Console][google-actions-console].

## Support

Got questions?

You have several options to get them answered:

- The [Home Assistant Discord Chat Server][discord].
- The Home Assistant [Community Forum][forum].
- Join the [Reddit subreddit][reddit] in [/r/homeassistant][reddit]

In case you've found a bug, please [open an issue on our GitHub][issue].

[aarch64-shield]: https://img.shields.io/badge/aarch64-no-red.svg
[amd64-shield]: https://img.shields.io/badge/amd64-yes-green.svg
[armhf-shield]: https://img.shields.io/badge/armhf-no-red.svg
[armv7-shield]: https://img.shields.io/badge/armv7-yes-green.svg
[dialogflow-integration]: https://www.home-assistant.io/integrations/dialogflow/
[discord]: https://discord.gg/c5DvZ4e
[forum]: https://community.home-assistant.io
[google-actions]: https://actions.google.com/
[google-actions-console]: https://console.actions.google.com/
[google-assistant-integration]: https://www.home-assistant.io/integrations/google_assistant/
[google-assistant]: https://assistant.google.com/
[google-oauth-client]: https://console.developers.google.com/apis/credentials/oauthclient
[google-platform-project]: https://console.cloud.google.com/project
[i386-shield]: https://img.shields.io/badge/i386-no-red.svg
[issue]: https://github.com/home-assistant/hassio-addons/issues
[reddit]: https://reddit.com/r/homeassistant
[repository]: https://github.com/hassio-addons/repository
