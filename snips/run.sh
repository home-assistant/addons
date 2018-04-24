#!/bin/bash
set -e

CONFIG_PATH=/data/options.json

MQTT_BRIDGE=$(jq --raw-output '.mqtt_bridge.active' $CONFIG_PATH)
ASSISTANT=$(jq --raw-output '.assistant' $CONFIG_PATH)
SPEAKER=$(jq --raw-output '.speaker' $CONFIG_PATH)
MIC=$(jq --raw-output '.mic' $CONFIG_PATH)
LANG=$(jq --raw-output '.language' $CONFIG_PATH| awk -F '-' '{print $1}')
CUSTOMTTS=$(jq --raw-output '.custom_tts' $CONFIG_PATH)
PLATFORM=$(jq --raw-output '.tts_platform' $CONFIG_PATH)
API_KEY=$(jq --raw-output '.api_key' // apikey $CONFIG_PATH)

if [ "$HOSTTYPE" == "x86_64" ]; then
    ARCH="amd64"
else
    ARCH="armhf"
fi
echo "[INFO] ARCH: $ARCH"

echo "[INFO] Show audio output devices"
aplay -l

echo "[INFO] Show audio input devices"
arecord -l

echo "[INFO] Setup audio device"
if [ -f "/share/asoundrc" ]; then
    echo "[INFO] - Installing /share/asoundrc"
    cp -v /share/asoundrc /root/.asoundrc
else
    echo "[INFO] - Using default asound.conf"
    sed -i "s/%%SPEAKER%%/$SPEAKER/g" /root/.asoundrc
    sed -i "s/%%MIC%%/$MIC/g" /root/.asoundrc
fi

echo "[DEBUG] Using /root/.asoundrc"
cat /root/.asoundrc

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
        echo "customtts = { command = [\"/usr/bin/customtts.sh\", \"$API_KEY\" \"$PLATFORM\", \"%%OUTPUT_FILE%%\", \"$LANG\", \"%%TEXT%%\"] }" >> /etc/snips.toml
    fi
else
    echo "[INFO] - Using default tts (picotts)"
fi

echo "[INFO] Copying mpg123 for $ARCH"
mv -v /usr/bin/mpg123-$ARCH /usr/bin/mpg123

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
    unzip -o -u "/share/$ASSISTANT" -d /usr/share/snips
# otherwise use the default 
else
    if [ -f "/share/assistant-Hass-$LANG.zip" ]; then
        echo "[INFO] - Using default assistant-Hass-$LANG.zip"
        unzip -o -u "/shareassistant-Hass-$LANG.zip" -d /usr/share/snips
    else
        echo "[ERROR] Could not find assistant!"
    fi
fi

echo "[INFO] Starting snips-watch"
( sleep 2; /usr/bin/snips-watch -vvv --no_color ) &

/opt/snips/snips-entrypoint.sh --mqtt localhost:1883
