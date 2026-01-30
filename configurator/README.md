# Home Assistant App: File editor

Browser-based configuration file editor for Home Assistant.

![Supports aarch64 Architecture][aarch64-shield] ![Supports amd64 Architecture][amd64-shield] ![Supports armhf Architecture][armhf-shield] ![Supports armv7 Architecture][armv7-shield] ![Supports i386 Architecture][i386-shield]

![Configurator in the Home Assistant Frontend][screenshot]

## About

The File editor, formerly known as Configurator, is a small web-app (you access it via web browser) that provides a
filesystem-browser and text-editor to modify files on the machine the File editor is
running on.

It is powered by Ace editor, which supports syntax highlighting for various
code/markup languages. YAML files (the default language for Home Assistant
configuration files) will be automatically checked for syntax errors while editing.

## Features

- Web-based editor to modify your files with syntax highlighting and YAML linting.
- Upload and download files.
- Stage, stash and commit changes in Git repositories, create and switch between
  branches, push to remotes, view diffs.
- Lists with available entities, triggers, events, conditions and services.
- Restart Home Assistant directly with the click of a button. Reloading groups,
  automations, etc. can be done as well. An API password is required.
- Direct links to Home Assistant documentation and icons.
- Execute shell commands within the app container.
- Editor settings are saved in your browser.
- And much more…

[aarch64-shield]: https://img.shields.io/badge/aarch64-yes-green.svg
[amd64-shield]: https://img.shields.io/badge/amd64-yes-green.svg
[armhf-shield]: https://img.shields.io/badge/armhf-yes-green.svg
[armv7-shield]: https://img.shields.io/badge/armv7-yes-green.svg
[i386-shield]: https://img.shields.io/badge/i386-yes-green.svg
[screenshot]: https://github.com/home-assistant/hassio-addons/raw/master/configurator/images/screenshot.png
