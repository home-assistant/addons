# Changelog

## 3.0.0

- Almond was rebranded to Genie and updated to version 3.0.0. This
  is a major release that significantly improves the supported skills
  and brings in more robust natural language understanding.
- The wake-word is now "Hey Genie".
- Voice support was overhauled and is now handled by a separate
  genie-client package. The client is included in the container for use
  with audio directly attached to Home Assistant, and can also be run
  separately on a different device.
- As with the previous release, all users are encouraged to upgrade
  as soon as possible to maintain compatibility with cloud services.

## 2.0.1

- Fix url for API requests

## 2.0.0

- Almond was updated to 2.0.0: this is a major release that
  brings significant changes to the supported skills. Additional
  details are in the release notes: https://wiki.genie.stanford.edu/release-planning/almond/two-point-oh
  All users are encouraged to upgrade as soon as possible, because
  the previous release line is unmaintained and unsupported. Cloud
  services that Almond relies on might drop compatibility with
  Almond 1.* at some point in the future.
- Voice support is now included in this addon, and the Ada add-on
  is not required (in fact, it should not be enabled at the same time).

## 1.1.2

- Revert restart nginx service on error

## 1.1.1

- Fix issue with some Almond packages

## 1.1.0

- Restart nginx service on error
- Use Alpine 3.13

## 1.0.1

- Keep unzip dependency installed

## 1.0.0

- Update Almond to 1.8.0
- Rewrite onto S6 overlay
- Reduce add-on image size
- Updates Supervisor API token and endpoint

## 0.9

- Update Almond to 1.7.3

## 0.8

- Update Almond to 1.7.2

## 0.7

- Change startup type to Application

## 0.6

- Fix issue with restart / Hass.io token handling

## 0.5

- Update Almond to 1.7.1

## 0.4

- Update Almond to 1.7.0

## 0.3

- Add automatic Almond setup

## 0.2

- Add Ingress
- Update almond to 1.6.0

## 0.1

- Initial version
