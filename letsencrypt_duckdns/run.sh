#!/bin/bash
set -e

CERT_DIR=/data/letsencrypt
WORK_DIR=/data/workdir
CONFIG_PATH=/data/options.json

DOMAIN=$(jq --raw-output '.domain' $CONFIG_PATH)

mkdir -p "$CERT_DIR"
mkdir -p "$WORK_DIR"

# Create empty dehydrated config file so that this dir will be used for storage
touch $WORK_DIR/config

# Generate new certs
if [ ! -d "$CERT_DIR/live" ]; then
  dehydrated --register --accept-terms --config $WORK_DIR/config
fi

dehydrated --cron --hook ./hooks.sh --challenge dns-01 --domain $DOMAIN --out $CERT_DIR  --config $WORK_DIR/config

# copy certs to store
cp "$CERT_DIR"/live/*/privkey.pem "/ssl/privkey.pem"
cp "$CERT_DIR"/live/*/fullchain.pem "/ssl/fullchain.pem"
