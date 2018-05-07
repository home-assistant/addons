#!/bin/bash
set -e

CONFIG_PATH=/data/options.json
CLIENT_JSON=/data/client.json
CRED_JSON=/data/cred.json

CLIENT_SECRETS=$(jq --raw-output '.client_secrets' $CONFIG_PATH)

# check if a new assistant file exists
if [ -f "/share/$CLIENT_SECRETS" ]; then
    echo "[Info] Install/Update service client_secrets file"
    cp -f "/share/$CLIENT_SECRETS" "$CLIENT_JSON"
fi

if [ ! -f "$CRED_JSON" ] && [ -f "$CLIENT_JSON" ]; then
    echo "[Info] Start WebUI for handling oauth2"
    python3 /hassio_oauth.py "$CLIENT_JSON" "$CRED_JSON"
elif [ ! -f "$CRED_JSON" ]; then
    echo "[Error] You need initialize GoogleAssistant with a client secret json!"
    exit 1
fi

exec python3 /hassio_gassistant.py "$CRED_JSON" < /dev/null
