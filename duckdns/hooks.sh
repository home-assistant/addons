#!/bin/bash
set -e

CONFIG_PATH=/data/options.json

DOMAINS=$(jq --raw-output '.domains | join(",")' $CONFIG_PATH)
TOKEN=$(jq --raw-output '.token' $CONFIG_PATH)
CERTFILE=$(jq --raw-output '.lets_encrypt.certfile' $CONFIG_PATH)
KEYFILE=$(jq --raw-output '.lets_encrypt.keyfile' $CONFIG_PATH)

# https://github.com/lukas2511/dehydrated/blob/master/docs/examples/hook.sh
case "$1" in
    "deploy_challenge")
        curl -s "https://www.duckdns.org/update?domains=$DOMAINS&token=$TOKEN&txt=$4"
        ;;
    "clean_challenge")
        curl -s "https://www.duckdns.org/update?domains=$DOMAINS&token=$TOKEN&txt=removed&clear=true"
        ;;
    "deploy_cert")
        cp -f "$5" "/ssl/$CERTFILE"
        cp -f "$3" "/ssl/$KEYFILE"
        ;;
esac
