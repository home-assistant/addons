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

echo "[INFO] Start install HomeAssistant $VERSION"

if ! PIP_OUTPUT="$(pip3 install "$CMD")"
then
    echo "[Error] Install HomeAssistant: $PIP_OUTPUT"
    exit 1
fi

echo "[Info] Install done, check config now"

cp -r /config /tmp/config > /dev/null
if ! HASS_OUTPUT="$(hass -c /tmp/config --script check_config)"
then
    echo "[Error] Wrong config found!"
    echo "$HASS_OUTPUT"
    exit 1
fi

if echo "$HASS_OUTPUT" | grep -i ERROR > /dev/null
then
    echo "[Error] Found error inside log output!"
    echo "$HASS_OUTPUT"
    exit 1
fi

echo "[Info] Finish :)"
