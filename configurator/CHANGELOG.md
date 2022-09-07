# Changelog

## 5.4.0

- Add Generate UUID menu item
- Harmonize Home Assistant term
- Rename Components to integrations
- Remove images for libraries
- Update jQuery to 3.6.0
- Update js-yaml to 4.1.0
- Update Ace Editor to 1.9.6

## 5.3.3

- Fix Home Assistant API endpoint

## 5.3.2

- Update base image to Alpine 3.14

## 5.3.1

- Update base image to Alpine 3.13

## 5.3.0

- Ignore input-keyword used in blueprints in yaml-linting

## 5.2.0

- Add git option which allows disabling the (default) git initialization

## 5.1.0

- Update base image to Alpine 3.12
- Add access to new media folder

## 5.0.0

- Rewrite add-on to S6 Overlay
- Reduced add-on size

## 4.7

- Fix file history width
- Store HASS-panel visibility state

## 4.6

- Fixed release, includes changes from 4.4:
  - Update Ace Editor to 1.4.8
  - Some online dependencies are now included in the package

## 4.5

- Reverts upgrade of hass-configurator as it is causing loading problems.

## 4.4

- Update Ace Editor to 1.4.8
- Some online dependencies are now included in the package

## 4.3

- Visual name change, the "Configurator", is now called the "File editor".

## 4.2

- Fixes an issue with the dirs first option

## 4.1

- Fixes an issue with the enforce base path option
- Enforce secure base path by default

## 4.0

- Removed direct access from the add-on, making the add-on Ingress only
- Extended list of default ignored patterns
- Simplified add-on code

## 3.7

- Rename files via UI
- Disable browser-autocomplete on searchbox
- Add file history button
- Update Ace Editor to 1.4.7

## 3.6

- UI Fix
- Update dependencies

## 3.5

- Add support for SSH keys

## 3.4

- Adds documentation to add-on repository
- Small code styling changes

## 3.3

- Fix issue with aarch64 and ingress

## 3.2

- Add `mdi:wrench` as panel icon
- Add options `ignore_pattern`

## 3.1

- Add options `dirsfirst` and `enforce_basepath`

## 3.0

- Update Python to version 3.7
- Update Configurator to version 0.3.5
- Migrate Add-on to new Ingress
- Pin Home Assistant requirements to 0.91.1

## 2.1

- Update python version

## 2.0

- Add access to folder: `/share`, `/backup`

## 1.2

- Update Configurator to version 0.3.2

## 1.1

- Fixed ssl certificate path bug

## 1.0

- Update Configurator to version 0.3.1

## 0.4

- Update Configurator to version 0.2.9

## 0.3

- Update Configurator to version 0.2.8

## 0.2.7

- Setting SO_REUSEADDR on socket for proper restarts
- Using Threading to handle multiple connections
- New VERIFY_HOSTNAME option to block requests without correct host header
- Fixed filebrowser hiding

## 0.2.6

- Displaying current filename in title
- Added menu item to open configurator in new tab
- Automatically load last viewed (and not closed) file via localStorage
- CTRL+s / CMD+s can now be used to save files
- Prompting before saving now opt-in in editor settings

## 0.2.5

- Added warning-logs for access failure
- Added transparency to whitespace characters
- Using external repository for Docker
- Modify BANNED_IPS and ALLOWED_NETWORKS at runtime
- Use relative paths in webserver
- Added "Sesame" feature

## 0.2.4

- YAML lint support
- Support new Hass.io token system
