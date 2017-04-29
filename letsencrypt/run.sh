#!/bin/bash
set -e

CERT_DIR=/data/letsencrypt
WORK_DIR=/data/workdir
CONFIG_PATH=/data/options.json

EMAIL=$(jq --raw-output ".email" $CONFIG_PATH)
DOMAINS=$(jq --raw-output ".domains[]" $CONFIG_PATH)
KEYFILE=$(jq --raw-output ".keyfile" $CONFIG_PATH)
CERTFILE=$(jq --raw-output ".certfile" $CONFIG_PATH)

# setup letsencrypt setup
if [ ! -f /data/certbot-auto ]; then
    cd /data
    curl -O https://dl.eff.org/certbot-auto
    chmod a+x certbot-auto
fi

# Start program
if [ -d $CERT_DIR ]; then
    /data/certbot-auto renew --non-interactive --config-dir $CERT_DIR --work-dir $WORK_DIR
else
    # generate domains
    for line in $DOMAINS; do
        if [ -z "$DOMAIN_ARG" ]; then
            DOMAIN_ARG="-d $line"
        else
            DOMAIN_ARG="$DOMAIN_ARG -d $line"
        fi
    done

    /data/certbot-auto certonly --non-interactive --standalone --email "$EMAIL" --config-dir $CERT_DIR --work-dir "$DOMAIN_ARG"
fi

# copy certs to store
cp /data/letsencrypt/live/*/privkey.pem "/ssl/$KEYFILE"
cp /data/letsencrypt/live/*/fullchain.pem "/ssl/$CERTFILE"
