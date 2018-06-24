#!/bin/bash
set -e

CONFIG_PATH=/data/options.json

MQTT_BRIDGE=$(jq --raw-output '.mqtt_bridge.active' $CONFIG_PATH)
ASSISTANT=$(jq --raw-output '.assistant' $CONFIG_PATH)
LANG=$(jq --raw-output '.language // "en"' $CONFIG_PATH)
CUSTOMTTS=$(jq --raw-output '.custom_tts.active' $CONFIG_PATH)
PLATFORM=$(jq --raw-output '.custom_tts.platform' $CONFIG_PATH)

echo "[INFO] LANG: $LANG"

echo "[INFO] Checking for /share/snips.toml"
if [ -f "/share/snips.toml" ]; then
    echo "[INFO] - Installing /share/snips.toml"
    cp -v /share/snips.toml /etc/
fi

if [ "$CUSTOMTTS" == "true" ]; then
    if [ -z "$PLATFORM" ]; then
        echo "[ERROR] - platform must be set to use custom tts!"
    else
        echo "[INFO] - Using custom tts"
        echo "provider = \"customtts\"" >> /etc/snips.toml
        echo "customtts = { command = [\"/usr/bin/customtts.sh\", \"$PLATFORM\", \"%%OUTPUT_FILE%%\", \"$LANG\", \"%%TEXT%%\"] }" >> /etc/snips.toml
    fi
else
    echo "[INFO] - Using default tts (picotts)"
fi

# mqtt bridge
if [ "$MQTT_BRIDGE" == "true" ]; then
    HOST=$(jq --raw-output '.mqtt_bridge.host' $CONFIG_PATH)
    PORT=$(jq --raw-output '.mqtt_bridge.port' $CONFIG_PATH)
    USER=$(jq --raw-output '.mqtt_bridge.user' $CONFIG_PATH)
    PASSWORD=$(jq --raw-output '.mqtt_bridge.password' $CONFIG_PATH)

    echo "[INFO] Setup internal mqtt bridge"

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

    {
        echo "topic hermes/intent/# out"
        echo "topic hermes/hotword/toggleOn out"
        echo "topic hermes/hotword/toggleOff out"
        echo "topic hermes/asr/stopListening out"
        echo "topic hermes/asr/startListening out"
        echo "topic hermes/nlu/intentNotParsed out"
        echo "topic hermes/audioServer/+/playBytes/# out"
        echo "topic hermes/audioServer/+/playFinished out"
        echo "topic # IN hermes/"
    } >> /etc/mosquitto.conf
fi

echo "[INFO] Start internal mqtt broker"
mosquitto -c /etc/mosquitto.conf &


echo "[INFO] Checking for updated $ASSISTANT in /share"
# check if a new assistant file exists
if [ -f "/share/$ASSISTANT" ]; then
    echo "[INFO] Install/Update snips assistant"
    rm -rf /usr/share/snips/assistant
    unzip -o -u "/share/$ASSISTANT" -d /usr/share/snips
# otherwise use the default 
else
    echo "[INFO] Checking for /assistant_Hass_$LANG.zip"
    if [ -f "/assistant_Hass_$LANG.zip" ]; then
        echo "[INFO] - Using default assistant_Hass_$LANG.zip"
        rm -rf /usr/share/snips/assistant
        unzip -o -u "/assistant_Hass_$LANG.zip" -d /usr/share/snips
    else
        echo "[ERROR] Could not find assistant!"
    fi
fi

echo "[INFO] Starting snips-watch"
( sleep 2; /usr/bin/snips-watch -vvv --no_color ) &

echo "[INFO] Starting snips-asr-injection"
( sleep 2; /usr/bin/snips-asr-injection -v --no_color ) &

/opt/snips/snips-entrypoint.sh --mqtt localhost:1883
