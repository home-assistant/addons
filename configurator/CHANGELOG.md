# Changelog

## 1.2

### Configurator 0.3.2
- Fixed numeric password regression
- Fixed list-options (ALLOWED_NETWORKS, BANNED_IPS, IGNORE_PATTERN)
- Improved handling of UTF-8 encoded files

## 1.1
- Fixed ssl certificate path bug

## 1.0

### Configurator 0.3.1
- Added basic git stash functionality
- Added NOTIFY_SERVICE option
- Notifying if used passwords are insecure and when SESAME has been used
- PASSWORD can optionally be provided as SHA256 hash
- Added SESAME_TOTP_SECRET for TOTP based IP whitelisting
- Added git diff functionality
- Red colored menu button as indicator for outdated version
- Removed right dragging area for editor settings
- Added IGNORE_SSL option to disable SSL verification when connecting to HASS API
- Allow customizing loglevel
- Show client IP address in network status modal

## 0.4
- Update Configurator to version 0.2.9
- Material Icons and HASS-help now open in new tab instead of modal
- Open file by URL
- Added ENFORCE_BASEPATH option
- Cosmetic fix for scaled viewports
- Added search-function for entities
- Updated Ace Editor to 1.3.3
- Updated jQuery to 3.3.1
- Updated js-yaml to 3.12.0

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
