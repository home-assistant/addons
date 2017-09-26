#!/bin/bash
set -e
set -u
set -o pipefail

CONFIG_PATH=/data/options.json

HASS_PASSWORD=$(jq --raw-output '.hass_password' $CONFIG_PATH)

case "$1" in
    "deploy_challenge")
        curl -X POST -H "Content-Type: application/json" -u homeassistant:$HASS_PASSWORD -d '{"txt": "$4"}' http://homeassistant:8123/api/services/duckdns/set_txt
        echo
        ;;
    "clean_challenge")
        curl -X POST -H "Content-Type: application/json" -u homeassistant:$HASS_PASSWORD -d '{"txt": null}' http://homeassistant:8123/api/services/duckdns/set_txt
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
