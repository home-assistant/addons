# Release documentation for developers

## Matter Server Update Procedure

When updating the server library in the add-on follow these steps:

1. Update the `MATTER_SERVER_VERSION` argument in `build.yaml`.
2. Check if the chip SDK version has changed in the server library.
3. If the chip SDK version has changed, set the `homeassistant` key in `config.yaml` to the minimum version of Home Assistant Core required to install or update the add-on. Home Assistant Core needs to have the exact same version of the chip SDK as the server.
4. Update the add-on version in `config.yaml`. Bump to a new major version if the chip SDK version was changed.
5. Update the changelog in `CHANGELOG.md`. Include a markdown link to the GitHub release of the server in the changelog.
