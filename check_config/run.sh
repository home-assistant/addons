#!/bin/bash
set -e

CONFIG_PATH=/data/options.json

VERSION=$(jq --raw-output ".version" $CONFIG_PATH)

# generate install string
if [ "$VERSION" == "latest" ]; then
    CMD="homeassistant"
else
    CMD="homeassistant==$VERSION"
fi

echo "[Info] Installing temporary Home Assistant $VERSION instance to test configuration..."

if ! PIP_OUTPUT="$(pip3 install "$CMD")"
then
    echo "[Error] Install error: $PIP_OUTPUT"
    exit 1
fi

INSTALLED_VERSION="$(pip freeze | grep homeassistant)"

echo "[Info] Install complete, checking configuration now..."

cp -fr /config /tmp/config
if ! HASS_OUTPUT="$(hass -c /tmp/config --script check_config)"
then
    echo "[Error] Invalid configuration detected!"
    echo "$HASS_OUTPUT"
    exit 1
fi

if echo "$HASS_OUTPUT" | grep -i ERROR > /dev/null
then
    echo "[Error] Found error in log output!"
    echo "$HASS_OUTPUT"
    exit 1
fi

echo "[Info] Configuration check finished - no error found! :)"
