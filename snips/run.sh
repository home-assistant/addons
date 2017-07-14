#!/bin/bash
set -e

CONFIG_PATH=/data/options.json
SNIPS_CONFIG=/data/config

MQTT_BRIDGE=$(jq --raw-output '.mqtt_bridge.active' $CONFIG_PATH)
ASSISTANT=$(jq --raw-output '.assistant' $CONFIG_PATH)
SPEAKER=$(jq --raw-output '.speaker' $CONFIG_PATH)
MIC=$(jq --raw-output '.mic' $CONFIG_PATH)

echo "[Info] Show audio device"
aplay -l

echo "[Info] Setup audio device"
sed -i "s/%%SPEAKER%%/$SPEAKER/g" /root/.asoundrc
sed -i "s/%%MIC%%/$MIC/g" /root/.asoundrc

# mqtt bridge
if [ "$MQTT_BRIDGE" == "true" ]; then
    HOST=$(jq --raw-output '.mqtt_bridge.host' $CONFIG_PATH)
    PORT=$(jq --raw-output '.mqtt_bridge.port' $CONFIG_PATH)
    USER=$(jq --raw-output '.mqtt_bridge.user' $CONFIG_PATH)
    PASSWORD=$(jq --raw-output '.mqtt_bridge.password' $CONFIG_PATH)

    echo "[Info] Setup internal mqtt bridge"

    {
        echo "connection main-mqtt"
        echo "address $HOST:$PORT"
    } >> /etc/mosquitto.conf

    if [ ! -z "$USER" ]; then
      {
          echo "username $USER"
          echo "password $PASSWORD"
      } >> /etc/mosquitto.conf
    fi

    echo "topic # OUT" >> /etc/mosquitto.conf
fi

echo "[Info] Start internal mqtt broaker"
mosquitto -c /etc/mosquitto.conf &

# init snips config
mkdir -p "$SNIPS_CONFIG"
ln -s /opt/snips/config "$SNIPS_CONFIG"

# check if a new assistant file exists
if [ -f "$ASSISTANT" ]; then
    unzip "$ASSISTANT" -u -d "$SNIPS_CONFIG"
fi

exec /opt/snips/snips-entrypoint.sh --mqtt localhost:1884
