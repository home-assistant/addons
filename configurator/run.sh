#!/bin/bash
set -e

CONFIG_PATH=/data/options.json

export HC_BASEPATH=/config
export HC_ENFORCE_BASEPATH=$(jq --raw-output '.enforce_basepath' $CONFIG_PATH)
export HC_HASS_API=http://hassio/homeassistant/api/
export HC_HASS_API_PASSWORD=$HASSIO_TOKEN
export HC_USERNAME=$(jq --raw-output '.username' $CONFIG_PATH)
export HC_PASSWORD=$(jq --raw-output '.password' $CONFIG_PATH)
export HC_VERIFY_HOSTNAME=$(jq --raw-output '.verify_hostname' $CONFIG_PATH)
export HC_NOTIFY_SERVICE=$(jq --raw-output '.notify_service' $CONFIG_PATH)
export HC_ALLOWED_NETWORKS=$(jq --raw-output '.allowed_networks | join(",")' $CONFIG_PATH)
export HC_BANNED_IPS=$(jq --raw-output '.banned_ips | join(",")' $CONFIG_PATH)
export HC_BANLIMIT=$(jq --raw-output '.banlimit' $CONFIG_PATH)
export HC_IGNORE_PATTERN=$(jq --raw-output '.ignore_pattern | join(",")' $CONFIG_PATH)
export HC_DIRSFIRST=$(jq --raw-output '.dirsfirst' $CONFIG_PATH)
export HC_GIT=true

if  [ $(jq --raw-output '.ssl' $CONFIG_PATH) == "true" ]; then
    export HC_SSL_CERTIFICATE=$(jq --raw-output '.certfile' $CONFIG_PATH)
    export HC_SSL_KEY=$(jq --raw-output '.keyfile' $CONFIG_PATH)
fi
LOGLEVEL=$(jq --raw-output '.loglevel' $CONFIG_PATH)
if [ $LOGLEVEL != "null" ]; then
    export HC_LOGLEVEL=$LOGLEVEL
fi
SESAME=$(jq --raw-output '.sesame' $CONFIG_PATH)
if [ $SESAME != "null" ]; then
    export HC_SESAME=$SESAME
fi
SESAME_TOTP_SECRET=$(jq --raw-output '.sesame_totp_secret' $CONFIG_PATH)
if [ $SESAME_TOTP_SECRET != "null" ]; then
    export HC_SESAME_TOTP_SECRET=$SESAME_TOTP_SECRET
fi

# Run configurator
exec python3 /configurator.py
