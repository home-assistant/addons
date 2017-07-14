#!/bin/bash
set -e

CONFIG_PATH=/data/options.json

MQTT_BRIDGE=$(jq --raw-output '.mqtt_bridge.active' $CONFIG_PATH)
ASSISTANT=$(jq --raw-output '.assistant' $CONFIG_PATH)

if [ "$MQTT_BRIDG" == "true" ]; then
    HOST=$(jq --raw-output '.mqtt_bridge.host' $CONFIG_PATH)
    PORT=$(jq --raw-output '.mqtt_bridge.port' $CONFIG_PATH)
    USER=$(jq --raw-output '.mqtt_bridge.user' $CONFIG_PATH)
    PASSWORD=$(jq --raw-output '.mqtt_bridge.password' $CONFIG_PATH)
  
    echo "[Info] Setup internal mqtt bridge"
  
    echo {
        "connection main-mqtt"
        "address $HOST:$PORT"
    } >> /etc/mosquitto.conf
  
    if [! -z "$USER"]; then
      echo {
          "username $USER"
          "password $PASSWORD"
      } >> /etc/mosquitto.conf
    fi
    
    echo "topic OUT #" >> /etc/mosquitto.conf
fi

echo "[Info] Start internal mqtt broaker"
mosquitto -c /etc/mosquitto.conf &


exec /opt/snips/snips-entrypoint.sh --mqtt localhost:1884
