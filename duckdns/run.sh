#!/bin/bash
set -e

CONFIG_PATH=/data/options.json

TOKEN=$(jq --raw-output ".token" $CONFIG_PATH)
DOMAINS=$(jq --raw-output ".domains[]" $CONFIG_PATH)
SECONDS=$(jq --raw-output ".seconds" $CONFIG_PATH)

for line in $DOMAINS; do
    if [ -z "$DOMAIN_ARG" ]; then
        DOMAIN_ARG="$line"
    else
        DOMAIN_ARG="$DOMAIN_ARG,$line"
    fi
done

#
while true; do
    curl -k "https://www.duckdns.org/update?domains=$DOMAIN_ARG&token=$TOKEN&ip=" || true
    sleep "$SECONDS"
done
