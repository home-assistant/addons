#!/bin/bash

set -e

CERT_DIR=/ssl/letsencrypt
CONFIG_PATH=/data/options.json

EMAIL=$(jq --raw-output ".email // empty" $CONFIG_PATH)
DOMAIN=$(jq --raw-output ".domain // empty" $CONFIG_PATH)

# setup letsencrypt setup
if [ ! -f /data/certbot-auto ]; then
    cd /data
    curl -O https://dl.eff.org/certbot-auto
    chmod 775 certbot-auto
fi

#
if [ -d $CERT_DIR ]; then
    ./data/certbot-auto renew -n --config-dir $CERT_DIR
else
    ./data/certbot-auto certonly -n --standalone --email $EMAIL --config-dir $CERT_DIR
fi
