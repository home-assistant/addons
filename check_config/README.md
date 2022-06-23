# Home Assistant Add-on: Check Home Assistant configuration

**WARNING: This add-on is deprecated because it is no longer needed. Home Assistant now always starts after an update even if your config is invalid. You should do the following after an update to check for issues:**

1. Check persistent notifications. If an integration could not be loaded because its config is invalid a notification will tell you.
2. Check logs. If an integration could be loaded but the config you are using is deprecated a message will tell you what needs to change and by when.
3. Follow the red banner. In rare cases HA will start in safe mode. In those cases you should follow the instructions in the red banner at the top of the UI.

Check your Home Assistant configuration against other versions.

![Supports aarch64 Architecture][aarch64-shield] ![Supports amd64 Architecture][amd64-shield] ![Supports armhf Architecture][armhf-shield] ![Supports armv7 Architecture][armv7-shield] ![Supports i386 Architecture][i386-shield]

You can use this add-on to check whether your configuration files are valid against the
new version of Home Assistant before you actually update your Home Assistant
installation. This add-on will help you avoid errors due to breaking changes,
resulting in a smooth update.

[aarch64-shield]: https://img.shields.io/badge/aarch64-yes-green.svg
[amd64-shield]: https://img.shields.io/badge/amd64-yes-green.svg
[armhf-shield]: https://img.shields.io/badge/armhf-yes-green.svg
[armv7-shield]: https://img.shields.io/badge/armv7-yes-green.svg
[i386-shield]: https://img.shields.io/badge/i386-yes-green.svg
