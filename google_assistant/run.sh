#!/usr/bin/env bashio
set -e

CLIENT_JSON=/data/client.json
CRED_JSON=/data/cred.json

PROJECT_ID=$(bashio::config 'project_id')
MODEL_ID=$(bashio::config 'model_id')

# check if a new assistant file exists
if bashio::fs.file_exists "/share/$(bashio::config 'client_secrets'); then
    bashio::log:info "Install/Update service client_secrets file"
    cp -f "/share/$(bashio::config 'client_secrets')" "$CLIENT_JSON"
fi

if ! bashio::fs.file_exists "${CRED_JSON}" && bashio::fs.file_exists "${CLIENT_JSON}"; then
    bashio::log:info "Start WebUI for handling oauth2"
    python3 /hassio_oauth.py "$CLIENT_JSON" "$CRED_JSON"
elif ! bashio::fs.file_exists "${CRED_JSON}"; then
    bashio::exit.nok "You need initialize GoogleAssistant with a client secret json!"
fi

bashio::log:info "Run Hass.io GAssisant SDK"
exec python3 /hassio_gassistant.py "$CRED_JSON" "$PROJECT_ID" "$MODEL_ID" < /dev/null
