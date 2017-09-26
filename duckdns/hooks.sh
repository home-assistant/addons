#!/bin/bash
set -e
set -u
set -o pipefail

CONFIG_PATH=/data/options.json

DOMAIN=$(jq --raw-output '.domains[0]' $CONFIG_PATH)
TOKEN=$(jq --raw-output '.token' $CONFIG_PATH)

case "$1" in
    "deploy_challenge")
        curl "https://www.duckdns.org/update?domains=$DOMAIN&token=$TOKEN&txt=$4"
        echo
        ;;
    "clean_challenge")
        curl "https://www.duckdns.org/update?domains=$DOMAIN&token=$TOKEN&txt=removed&clear=true"
        echo
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
