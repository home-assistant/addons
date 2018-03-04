#!/bin/bash
set -e

CONFIG_PATH=/data/options.json

CERTFILE=$(jq --raw-output '.lets_encrypt.certfile' $CONFIG_PATH)
KEYFILE=$(jq --raw-output '.lets_encrypt.keyfile' $CONFIG_PATH)

case "$1" in
    "deploy_challenge")
        ;;
    "clean_challenge")
        ;;
    "deploy_cert")
        cp -f "$5" "/ssl/$CERTFILE"
        cp -f "$3" "/ssl/$KEYFILE"
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
