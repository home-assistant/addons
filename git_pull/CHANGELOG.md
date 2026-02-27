# Changelog

## 9.0.0

- Update base image to Alpine 3.23
- Drop unsupported architectures
- Remove advanced flag in the app config

## 8.0.1
- Fix bashio warn(ing) logger usage breaking deployment keys

## 8.0.0
- Refactor git_pull to use HA Api with bashio
- Update base image to Alpine 3.21
- Remove ha cli dependency


## 7.14.1
- Fix error where $HOME is not defined

## 7.14.0

- Update base image to Alpine 3.19
- Update Home Assistant CLI to 4.31.0

## 7.13.1

- Update Home Assistant CLI to 4.12.2

## 7.13.0

- Update Home Assistant CLI to 4.12.1
- Upgrade base image to Alpine 3.13
- Supress a shellcheck warning happening in CI

## 7.12.2

- Update Home Assistant CLI to 4.11.0

## 7.12.1

- Update options schema for passwords

## 7.12.0

- Fix error of deployment_key eventually failing by overwriting the deployment_key every cycle

## 7.11.0

- Update Home Assistant CLI to 4.2.0

## 7.10.0

- Update Home Assistant CLI to 4.1.0

## 7.9.0

- Update Home Assistant CLI to 4.0.1

## 7.8.0

- Added support for Azure DevOps repositories by removing the requirement for the `.git` suffix
- Update to Alpine 3.11

## 7.7.0

- Update Hass.io CLI to 3.1.1

## 7.6.0

- Update Hass.io CLI to 3.1.0

## 7.5.0

- Update Hass.io CLI to 3.0.0

## 7.4.0

- Update Hass.io CLI to 2.3.0

## 7.3.0

- Update Hass.io CLI to 2.2.0

## 7.2.0

- Fix restart_ignore when specifying a sub-directory

## 7.1.0

- Enhance restart_ignore to support whole directories
- Fix repeat option: don't terminate if internet connection unavailable during a check

## 7.0.0

- Update Hass.io CLI to 2.0.1

## 6.1.0

- Bugfix in git diff command while comparing commits

## 6.0.0

- Allow to disable Home Assistant restart for specific file changes
