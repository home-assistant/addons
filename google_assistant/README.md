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

You first need to enable access to the Google Assistant API.
To do so, do the following:

1. Go to the [Google Actions Console][google-actions-console] and create a new project.
1. After you created the project on the bottom of the page click on "**Device registration**". Keep this tab open for later use.
1. Enable the Google Assistant API on the new project through [this][google-assistant-api] link. Make sure you have the right project selected (shown in the middle of the screen in the top bar). If you can't select the right project, it may help to open the link in an incognito window.
1. Configure the [OAuth consent screen][google-oauth-concent]. Again, check that you have the right project.
    1. Choose "**External**" as the User Type.
    1. Fill in a project name and your e-mail.
    1. Hit <kbd>Save</kbd> at the bottom of the page.
1. Go back to you device registration tab and click on <kbd>REGISTER MODEL</kbd>. If you closed the tab, you can also open you project in the [Google Actions Console][google-actions-console], start the Quick setup, and in the left bar click "**Device registration**".
    1. Give you project a name and think of a nice manufacturer. Select "**speaker**" for the device type. If you want to, edit your model id, and copy it for later use.
    1. Click <kbd>REGISTER MODEL</kbd>, and download the credentials.
    1. Click <kbd>Next</kbd> and click <kbd>SKIP</kbd>.
1. Upload your credentials as `google_assistant.json` to the "hassio/share" folder, for example by using the [Samba][samba-addon] add-on.
1. On the add-on Configuration tab:
    1. In the "Config" section, fill-in you `project_id` and your `model_id` and hit <kbd>Save</kbd>. Your project id can be found in the Google Actions console by clicking on the top right menu button and selecting "**Project settings**". This id may differ from the project name that you choose!
    1. In the "Audio" section, select the input and output audio devices to use for the Assistant and hit <kbd>Save</kbd>. On a Raspberry Pi 3, `ALSA device 0` is the built-in headset port and `ALSA device 1` is the HDMI port.
1. The final step is to authenticate your Google account with Google Assistant.
    1. Start the add-on. Check the log and click refresh till it says: `ENGINE Bus STARTED`.
    1. Now click <kbd>Open Web UI</kbd> and follow the authentication process.
    1. Once you've signed in with Google and authorized the app, copy the code back in the web UI. You will get an empty response after you have send your token.
    1. After that, you can close the web UI tab.

Google Assistant should now be running on your Raspberry Pi!
To test it, say "Ok Google", following by the command of your choice.

## Troubleshooting

### Google Assistant is not working

Google needs to be able to send data back to your Google Assistant SDK Add-on by sending webhooks to `https://yourdomain:yourport/api/google_assistant`.

To do so, you need to make sure that your Home Assistant is accessible from the internet and that it's using `https` (SSL).

### The assistant voice volume is too low

If the voice of the assistant is really low, you can ask it to increase the volume:
- "Ok Google, set volume to maximum."
- or "Ok Google, set volume to 85%."

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
