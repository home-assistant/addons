#!/bin/bash
# shellcheck disable=SC2155

CONFIG_PATH=/data/options.json

export HC_BASEPATH=/config
export HC_HASS_API=http://hassio/homeassistant/api/
export HC_HASS_API_PASSWORD=$HASSIO_TOKEN
export HC_GIT=true
export HC_VERIFY_HOSTNAME=false
export HC_IGNORE_SSL=false

export HC_ENFORCE_BASEPATH=$(jq --raw-output '.enforce_basepath' $CONFIG_PATH)
export HC_USERNAME=$(jq --raw-output '.username' $CONFIG_PATH)
export HC_PASSWORD=$(jq --raw-output '.password' $CONFIG_PATH)
export HC_NOTIFY_SERVICE=$(jq --raw-output '.notify_service' $CONFIG_PATH)
export HC_ALLOWED_NETWORKS=$(jq --raw-output '.allowed_networks | join(",")' $CONFIG_PATH)
export HC_BANNED_IPS=$(jq --raw-output '.banned_ips | join(",")' $CONFIG_PATH)
export HC_BANLIMIT=$(jq --raw-output '.banlimit' $CONFIG_PATH)
export HC_IGNORE_PATTERN=$(jq --raw-output '.ignore_pattern | join(",")' $CONFIG_PATH)
export HC_DIRSFIRST=$(jq --raw-output '.dirsfirst' $CONFIG_PATH)
export HC_VERIFY_HOSTNAME=$(jq --raw-output '.verify_hostname // empty' $CONFIG_PATH)

SSL=$(jq --raw-output '.ssl // false' $CONFIG_PATH)
if  [ "$SSL" == "true" ]; then
    export HC_SSL_CERTIFICATE=ssl/$(jq --raw-output '.certfile' $CONFIG_PATH)
    export HC_SSL_KEY=ssl/$(jq --raw-output '.keyfile' $CONFIG_PATH)
fi

LOGLEVEL=$(jq --raw-output '.loglevel // empty' $CONFIG_PATH)
if [ ! -z "$LOGLEVEL" ]; then
    export HC_LOGLEVEL=$LOGLEVEL
fi

SESAME=$(jq --raw-output '.sesame // empty' $CONFIG_PATH)
if [ ! -z "$SESAME" ]; then
    export HC_SESAME=$SESAME
fi

SESAME_TOTP_SECRET=$(jq --raw-output '.sesame_totp_secret // empty' $CONFIG_PATH)
if [ ! -z "$SESAME_TOTP_SECRET" ]; then
    export HC_SESAME_TOTP_SECRET=$SESAME_TOTP_SECRET
fi

# Run configurator
exec python3 /configurator.py
