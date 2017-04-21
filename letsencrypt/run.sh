#!/bin/bash

set -e

CERT_DIR=/ssl/letsencrypt
CONFIG_PATH=/data/options.json

EMAIL=$(jq --raw-output ".email" $CONFIG_PATH)
DOMAINS=$(jq --raw-output ".domains[]" $CONFIG_PATH)

# setup letsencrypt setup
if [ ! -f /data/certbot-auto ]; then
    cd /data
    curl -O https://dl.eff.org/certbot-auto
    chmod 775 certbot-auto
fi

# Start program
if [ -d $CERT_DIR ]; then
    ./data/certbot-auto renew -n --config-dir $CERT_DIR
else
    # generate domains
    echo $DOMAINS | while read -r line; do
        if [ -z DOMAIN_ARG ]; do
            DOMAIN_ARG="-d $line"
        else
            DOMAIN_ARG="$DOMAIN_ARG -d $line"
        fi
    done

    ./data/certbot-auto certonly -n --standalone --email $EMAIL --config-dir $CERT_DIR $DOMAIN_ARG
fi
