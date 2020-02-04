# Home Assistant Add-on: Google Assistant SDK

Load and update configuration files for Home Assistant from a Git repository.

![Supports aarch64 Architecture][aarch64-shield] ![Supports amd64 Architecture][amd64-shield] ![Supports armhf Architecture][armhf-shield] ![Supports armv7 Architecture][armv7-shield] ![Supports i386 Architecture][i386-shield]

## About

[Google Assistant][google-assistant] is an AI-powered voice assistant that runs on the Raspberry Pi and x86 platforms and interact via the [DialogFlow][dialogflow-integration] integration with Home-Assistant. You can also use [Google Actions][google-actions] to extend its functionality.

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

1. Go to the [Google Actions Console][oogle-actions-console] and create a new project.
1. After you created the project on the bottom of the page click "Device registration". Keep this tab open for later use.
1. Enable the Google Assistant API on the new project through [this][google-assistant-api] link. Make sure you have the right project selected (shown in the middle of the screen in the top bar). If you can't select the right project, it may help to open the link in an incognito window.
1. Configure the [OAuth consent screen][google-oauth-concent]. Also again check that you have the right project and don't forget to hit "Save" at the bottom of the page. You only have to fill in a project name and your e-mail.
1. You back to you device registration tab and click "Device registration". Or open you project in the [Google Actions Console][google-actions-console] start the Quick setup, and in the left bar click "Device registration".
1. Give you project a name, think of a nice manufacturer and for device type select "speaker".
1. Edit you "model id", if you want to and copy it for later use.
1. Download the credentials.
1. Click "Next" and click "Skip".
1. Upload your credentials as "google_assistant.json" to the "hassio/share" folder, for example by using the [Samba][samba-addon] add-on.
1. In the Add-on configuration field fill-in you "project id" and your "model-id" and hit "Save". Your project id can be found in the Google Actions console by clicking on the top right menu button and selecting "Project settings". This id may differ from the project name that you choose!
1. Below the "Config" window select the microphone and speaker that you want to use. On a Raspberry Pi 3, ALSA device 0 is the built-in headset port and ALSA device 1 is the HDMI port. Also don't forget to click "Save".
1. Start the add-on. Check the log and click refresh till it says: "ENGINE Bus STARTED".
1. Now click "Open Web UI" and follow the authentication process. You will get an empty response after you have send your token.

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

The project id can be found in your "google_assistant.json" file or under project settings in the [Google Actions Console][google-actions-console].

### Option: `model_id` (required)

The ID of the model you've registered at Google for this add-on.

The model id can also be found under the "Develop - Device registration tab" in the [Google Actions Console][google-actions-console].

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
[google-oauth-concent]: https://console.developers.google.com/apis/credentials/consent
