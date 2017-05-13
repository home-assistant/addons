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
    echo "[ERROR] Install HomeAssistant: $PIP_OUTPUT"
    exit 1
fi

echo "[INFO] Install done, check config now"

cp -r /config /tmp/config > /dev/null
if ! HASS_OUTPUT="$(hass -c /tmp/config --script check_config)"
then
    echo "[ERROR] Wrong config found: $HASS_OUTPUT"
    exit 1
fi

echo "[INFO] Okay :)"
