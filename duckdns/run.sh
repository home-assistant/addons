#!/bin/bash
set -e

CONFIG_PATH=/data/options.json

TOKEN=$(jq --raw-output '.token' $CONFIG_PATH)
DOMAINS=$(jq --raw-output '.domains | join(",")' $CONFIG_PATH)
WAIT_TIME=$(jq --raw-output '.seconds' $CONFIG_PATH)

IP_V4=$(dig +short myip.opendns.com @resolver1.opendns.com | grep -v "connection timed out")
IP_V6=$(dig +short -6 myip.opendns.com aaaa @resolver1.ipv6-sandbox.opendns.com | grep -v "connection timed out")

# Run duckdns
while true; do
    ANSWER="$(curl -sk "https://www.duckdns.org/update?domains=$DOMAINS&token=$TOKEN&ip=$IP_V4&ipv6=IP_V6&verbose=true")" || true
    echo "$(date): $ANSWER"
    sleep "$WAIT_TIME"
done
