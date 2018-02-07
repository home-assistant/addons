# Changelog

## 4.3
- Downgrade Hass.io CLI to 1.0.1

## 4.2
- Update Hass.io CLI to 1.1.1

## 4.1
- Add support for key validation against ssh cloned GitHub repositories

## 4.0
- Allow to use user/password authentication for GIT
- New options `deployment_user` and `deployment_password`

## 3.0
- New CLI
- Update base image
- Backup of files before clearing the /config folder
- Copy back all non YAML files and the secrets.yaml after the git clone
- More verbose error handling. Also logging the GIT exceptions.
- Splitted code out into functions
- Check SSH connection before setting the key
