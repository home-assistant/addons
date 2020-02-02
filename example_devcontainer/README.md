# Hass.io Add-on Devcontainer Template

### Summary

This is a templated to ease development of Hass.io add-ons inside of a VS Code [devcontainer](https://code.visualstudio.com/docs/remote/containers)

### Usage 

Simply copy the contents of this repository to the base directory of the add-on you are developing.  Modify the files in the directory as needed.  

Your add-on will be appear in the `Local Add-ons` section of the Hass.io Add-On Store tab.

#### VS Code Tasks

The following tasks are included for your convenience.

- Start Hass.io

This task will download and run a Hass.io environment inside the container using the latest `dev` targets of Hass.io and Home Assistant.  It will be mapped to port 8123 (by default) on the host machine

- Run Hass.io CLI - _Requires a running Hass.io_

This task will open a Hass.io CLI window inside VS Code

- Cleanup stale Hass.io environment

This task will nuke the data stored by Hass.io (including the underlying Home Assistant).  Can be used to revert to a pristine state before starting Hass.io

### FAQ

Q: How do I customize some-widget-or-another?

A: There is almost no "black magic" going on here.  Make sure to read up on how devcontainers work from the [official website](https://code.visualstudio.com/docs/remote/containers)

Q: I read the docs.  I still need help customizing some-widget-or-another!

A: Come ask on [Discord](https://discordapp.com/invite/2Uath3J) in channel #hassio_dev

Q: How do I develop more than one add-on in the same Hass.io instance?

A: See [this issue](https://github.com/issacg/hassio-addon-devcontainer/issues/1).

Q: Why are there 2 `Dockerfile`s?  

A: The `.devcontainer\Dockerfile` is for your development environment.  The `Dockerfile` in the root directory is to build your Add-on.

Q: I added `.devcontainer` to my `.dockerignore` and now things are broken.

A: Don't.  The `.dockerignore` is shared by both Dockerfiles, and by adding `.devcontainer` to your `.dockerignore`, you will break things in the devcontainer.  Instead, use other means to avoid copying `.devcontainer` (and `.vscode` for that matter) in your "production" `Dockerfile`.
