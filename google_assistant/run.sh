#!/bin/bash
set -e

CONFIG_PATH=/data/options.json
OAUTH_JSON=/data/auth.json

SERVICE_ACCOUNT=$(jq --raw-output '.service_account' $CONFIG_PATH)
SPEAKER=$(jq --raw-output '.speaker' $CONFIG_PATH)
MIC=$(jq --raw-output '.mic' $CONFIG_PATH)

echo "[Info] Show audio device"
aplay -l

echo "[Info] Setup audio device"
sed -i "s/%%SPEAKER%%/$SPEAKER/g" /root/.asoundrc
sed -i "s/%%MIC%%/$MIC/g" /root/.asoundrc

# check if a new assistant file exists
if [ -f "/share/$SERVICE_ACCOUNT" ]; then
    echo "[Info] Install/Update service account key file"
    cp -f "/share/$SERVICE_ACCOUNT" "$OAUTH_JSON"
fi

exec python3 /hassio_gassistant.py "$OAUTH_JSON" < /dev/null
