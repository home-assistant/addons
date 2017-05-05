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

# Generate new certs
if [ ! -d "$CERT_DIR" ]; then
    for line in $DOMAINS; do
        if [ -z "$DOMAIN_ARG" ]; then
            DOMAIN_ARG="-d $line"
        else
            DOMAIN_ARG="$DOMAIN_ARG -d $line"
        fi
    done

    echo "$DOMAINS" > /data/domains.gen
    /data/certbot-auto certonly --non-interactive --standalone --email "$EMAIL" --config-dir "$CERT_DIR" --work-dir "$DOMAIN_ARG"

# Renew certs
else
    /data/certbot-auto renew --non-interactive --config-dir "$CERT_DIR" --work-dir "$WORK_DIR"
fi

# copy certs to store
cp "$CERT_DIR"/live/*/privkey.pem "/ssl/$KEYFILE"
cp "$CERT_DIR"/live/*/fullchain.pem "/ssl/$CERTFILE"
