You first need to enable access to the Google Assistant API.
To do so, do the following:

1. Go to the [Google Actions Console][google-actions-console] and create a new project.
1. After you created the project on the bottom of the page click on "**Device registration**". Keep this tab open for later use.
1. Enable the Google Assistant API on the new project through [this][google-assistant-api] link. Make sure you have the right project selected (shown in the middle of the screen in the top bar). If you can't select the right project, it may help to open the link in an incognito window.
1. Configure the [OAuth consent screen][google-oauth-concent]. Again, check that you have the right project.
    1. Choose "**External**" as the User Type.
    1. Fill in a project name and your e-mail.
    1. Hit "**Save**" at the bottom of the page.
1. Go back to you device registration tab and click on "**REGISTER MODEL**". If you closed the tab, you can also open you project in the [Google Actions Console][google-actions-console], start the Quick setup, and in the left bar click "**Device registration**".
    1. Give you project a name and think of a nice manufacturer. Select "**speaker**" for the device type. If you want to, edit your model id, and copy it for later use.
    1. Click "**REGISTER MODEL**", and download the credentials.
    1. Click "**Next**" and click "**SKIP**".
1. Upload your credentials as `google_assistant.json` to the "hassio/share" folder, for example by using the [Samba][samba-addon] add-on.
1. On the add-on Configuration tab:
    1. In the "Config" section, fill-in you `project_id` and your `model_id` and hit "**Save**". Your project id can be found in the Google Actions console by clicking on the top right menu button and selecting "**Project settings**". This id may differ from the project name that you choose!
    1. In the "Audio" section, select the input and output audio devices to use for the Assistant and hit "**Save**". On a Raspberry Pi 3, `ALSA device 0` is the built-in headset port and `ALSA device 1` is the HDMI port.
1. The final step is to authenticate your Google account with Google Assistant.
    1. Start the add-on. Check the log and click refresh till it says: `ENGINE Bus STARTED`.
    1. Now click "**Open Web UI**" and follow the authentication process.
    1. Once you've signed in with Google and authorized the app, copy the code back in the web UI. You will get an empty response after you have send your token.
    1. After that, you can close the web UI tab.

Google Assistant should now be running on your Raspberry Pi!
To test it, say "Ok Google", following by the command of your choice.

### Troubleshooting

#### Google Assistant is not working

Google needs to be able to send data back to your Google Assistant SDK Add-on by sending webhooks to `https://yourdomain:yourport/api/google_assistant`.

To do so, you need to make sure that your Home Assistant is accessible from the internet and that it's using `https` (SSL).

#### The assistant voice volume is too low

If the voice of the assistant is really low, you can ask it to increase the volume:
- "Ok Google, set volume to maximum."
- or "Ok Google, set volume to 85%."

[google-actions-console]: https://console.actions.google.com/
[google-assistant-api]: https://console.developers.google.com/apis/api/embeddedassistant.googleapis.com/overview
[google-oauth-concent]: https://console.developers.google.com/apis/credentials/consent
[samba-addon]: https://github.com/home-assistant/hassio-addons/tree/master/samba
