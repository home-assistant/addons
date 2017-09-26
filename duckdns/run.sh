#!/bin/bash
set -e

CERT_DIR=/data/letsencrypt
WORK_DIR=/data/workdir
CONFIG_PATH=/data/options.json

LE_TERMS=$(jq --raw-output ".accept_lets_encrypt_terms" $CONFIG_PATH)
TOKEN=$(jq --raw-output '.token' $CONFIG_PATH)
DOMAINS=$(jq --raw-output '.domains | join(",")' $CONFIG_PATH)
WAIT_TIME=$(jq --raw-output '.seconds' $CONFIG_PATH)

# Register/generate certificate if terms accepted
if [ "$LE_TERMS" == "true" ]; then
  # Only use first domain for Let's Encrypt
  DOMAIN=$(jq --raw-output '.domains[0]' $CONFIG_PATH)

  mkdir -p "$CERT_DIR"
  mkdir -p "$WORK_DIR"

  # Create empty dehydrated config file so that this dir will be used for storage
  touch $WORK_DIR/config

  # Generate new certs
  if [ ! -d "$CERT_DIR/live" ]; then
    dehydrated --register --accept-terms --config $WORK_DIR/config
  fi

  dehydrated --cron --hook ./hooks.sh --challenge dns-01 --domain $DOMAIN --out $CERT_DIR  --config $WORK_DIR/config
fi

# Run duckdns
while true; do
    ANSWER="$(curl -sk "https://www.duckdns.org/update?domains=$DOMAINS&token=$TOKEN&ip=&verbose=true")" || true
    echo "$(date): $ANSWER"
    sleep "$WAIT_TIME"
done
