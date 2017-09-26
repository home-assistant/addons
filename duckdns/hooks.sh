#!/bin/bash
set -e

CONFIG_PATH=/data/options.json

DOMAINS=$(jq --raw-output '.domains | join(",")' $CONFIG_PATH)
TOKEN=$(jq --raw-output '.token' $CONFIG_PATH)

case "$1" in
    "deploy_challenge")
        curl -s "https://www.duckdns.org/update?domains=$DOMAINS&token=$TOKEN&txt=$4"
        ;;
    "clean_challenge")
        curl -s "https://www.duckdns.org/update?domains=$DOMAINS&token=$TOKEN&txt=removed&clear=true"
        ;;
    "deploy_cert")
        ;;
    "unchanged_cert")
        ;;
    "startup_hook")
        ;;
    "exit_hook")
        ;;
    *)
        echo Unknown hook "${1}"
        exit 0
        ;;
esac
