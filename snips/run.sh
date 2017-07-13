#!/bin/bash
set -e

CONFIG_PATH=/data/options.json

MQTT_BRIDGE=$(jq --raw-output '.mqtt_bridge' $CONFIG_PATH)
MQTT_HOST=$(jq --raw-output '.mqtt_host' $CONFIG_PATH)
MQTT_PORT=$(jq --raw-output '.mqtt_port' $CONFIG_PATH)
MQTT_USER=$(jq --raw-output '.mqtt_user' $CONFIG_PATH)
MQTT_PASSWORD=$(jq --raw-output '.mqtt_password' $CONFIG_PATH)
ASSISTANT=$(jq --raw-output '.assistant' $CONFIG_PATH)


exec /opt/snips/snips-entrypoint.sh
