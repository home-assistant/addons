# Hass.io Core Add-on: Google Assistant SDK

Load and update configuration files for Home Assistant from a Git repository.

![Supports aarch64 Architecture][aarch64-shield] ![Supports amd64 Architecture][amd64-shield] ![Supports armhf Architecture][armhf-shield] ![Supports armv7 Architecture][armv7-shield] ![Supports i386 Architecture][i386-shield]

## About

[Google Assistant][google-assistant] is an AI-powered voice assistant that runs on the Raspberry Pi and x86 platforms and interact via the [DialogFlow][dialogflow-integration] integration with Home-Assistant. You can also use [Google Actions][google-actions] to extend its functionality.

## ⚠️ These instructions are outdated

These instructions are outdated - the add-on has been updated and these are no longer accurate or complete.
Any help in improving the add-on or this document is highly appreciated.

## ℹ️ Integration your mobile or Google/Nest Home with Home Assistant

If you want to integrate your Google Home or mobile phone running Google Assistant, with Home Assistant, then you want the [Google Assistant integration][google-assistant-integration].

## Installation

Follow these steps to get the add-on installed on your system:

1. Navigate in your Home Assistant frontend to **Hass.io** -> **Add-on Store**.
2. Find the "Google Assistant SDK" add-on and click it.
3. Click on the "INSTALL" button.

## How to use

Fist, select the input and output audio devices to use for the Assistant in the "Audio" section of the add-on configuration.

To enable access to the Google Assistant API, do the following:

1. In the [Cloud Platform Console][google-platform-project], go to the Projects page. Select an existing project or create a new project
1. Open the project. In the top of the page search for Google Assistant API or use [this link][google-assistant-api] and enable it.
1. Create an [OAuth Client ID][google-oauth-client], pick type "Other", click "Create" and download the JSON file by clicking the Download JSON button on the right side.

Now install and activate the [Samba][samba-addon] add-on so you can upload your credential file. Connect to the "share" Samba share and copy your credentials over. Name the file `google_assistant.json`.

The next step is to authenticate your Google account with Google Assistant. Start the add-on and click on the "OPEN WEB UI" button to start authentication.

## Configuration

Add-on configuration:

```json
{
  "client_secrets": "google_assistant.json",
  "project_id": "project_id_from_google",
  "model_id": "model_id_from_google"
}
```

### Option: `clients_secrets` (required)

The name of the client secrets file to you've downloaded from Google and placed in your `/share` folder.

### Option: `project_id` (required)

Project ID of the project you've created at Google for this add-on.

### Option: `model_id` (required)

The ID of the model you've registered at Google for this add-on.

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
[google-assistant-api]: https://console.developers.google.com/apis/api/embeddedassistant.googleapis.com/overview
[google-assistant-integration]: https://www.home-assistant.io/integrations/google_assistant/
[google-assistant]: https://assistant.google.com/
[google-oauth-client]: https://console.developers.google.com/apis/credentials/oauthclient
[google-platform-project]: https://console.cloud.google.com/project
[i386-shield]: https://img.shields.io/badge/i386-no-red.svg
[issue]: https://github.com/home-assistant/hassio-addons/issues
[reddit]: https://reddit.com/r/homeassistant
[repository]: https://github.com/hassio-addons/repository
[samba-addon]: https://github.com/home-assistant/hassio-addons/tree/master/samba
