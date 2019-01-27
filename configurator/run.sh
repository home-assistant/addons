#!/bin/bash
# shellcheck disable=SC2155

CONFIG_PATH=/data/options.json

export HC_BASEPATH=/config
export HC_HASS_API=http://hassio/homeassistant/api/
export HC_HASS_API_PASSWORD=$HASSIO_TOKEN
export HC_GIT=true
export HC_IGNORE_SSL=false
export HC_LISTENIP=127.0.0.1
export HC_PORT=80

export HC_ENFORCE_BASEPATH=$(jq --raw-output '.enforce_basepath' $CONFIG_PATH)
export HC_IGNORE_PATTERN=$(jq --raw-output '.ignore_pattern | join(",")' $CONFIG_PATH)
export HC_DIRSFIRST=$(jq --raw-output '.dirsfirst' $CONFIG_PATH)

SSL=$(jq --raw-output '.ssl // false' $CONFIG_PATH)
if  [ "$SSL" == "true" ]; then
    export HC_SSL_CERTIFICATE=ssl/$(jq --raw-output '.certfile' $CONFIG_PATH)
    export HC_SSL_KEY=ssl/$(jq --raw-output '.keyfile' $CONFIG_PATH)
fi

LOGLEVEL=$(jq --raw-output '.loglevel // empty' $CONFIG_PATH)
if [ -n "$LOGLEVEL" ]; then
    export HC_LOGLEVEL=$LOGLEVEL
fi

SESAME=$(jq --raw-output '.sesame // empty' $CONFIG_PATH)
if [ -n "$SESAME" ]; then
    export HC_SESAME=$SESAME
fi

SESAME_TOTP_SECRET=$(jq --raw-output '.sesame_totp_secret // empty' $CONFIG_PATH)
if [ -n "$SESAME_TOTP_SECRET" ]; then
    export HC_SESAME_TOTP_SECRET=$SESAME_TOTP_SECRET
fi

HASS_WS_API=$(jq --raw-output '.hass_ws_api // empty' $CONFIG_PATH)
if [ ! -z "$HASS_WS_API" ]; then
    export HC_HASS_WS_API=$HASS_WS_API
fi

# Run configurator
exec python3 /configurator.py
