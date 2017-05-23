#!/bin/bash
set -e

CONFIG_PATH=/data/options.json

TOKEN=$(jq --raw-output '.token' $CONFIG_PATH)
DOMAINS=$(jq --raw-output '.domains | join(",")' $CONFIG_PATH)
WAIT_TIME=$(jq --raw-output '.seconds' $CONFIG_PATH)

# Run duckdns
while true; do
    ANSWER="$(curl -sk "https://www.duckdns.org/update?domains=$DOMAINS&token=$TOKEN&ip=&verbose=true")"
    echo "$(date): $ANSWER"
    sleep "$WAIT_TIME"
done
