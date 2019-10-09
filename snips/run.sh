#!/usr/bin/env bashio
set -e

ASSISTANT=$(bashio::config 'assistant')
LANG=$(bashio::config 'language')
CUSTOMTTS=$(bashio::config 'custom_tts.active')

bashio::log.info "LANG: ${LANG}"
bashio::log.info "Checking for /share/snips.toml"

if bashio::fs.file_exists "/share/snips.toml"; then
    bashio::log.info "Installing /share/snips.toml"
    cp -v /share/snips.toml /etc/
fi

if bashio::config.true 'custom_tts.active'; then
    PLATFORM=$(bashio::config 'custom_tts.platform')

    if ! bashio::config.has_value 'custom_tts.platform'; then
        bashio::exit.nok "platform must be set to use custom tts!"
    else
        bashio::log.info "Using custom tts"
        (
            echo "provider = \"customtts\""
            echo "customtts = { command = [\"/usr/bin/customtts.sh\", \"${PLATFORM}\", \"%%OUTPUT_FILE%%\", \"${LANG}\", \"%%TEXT%%\"] }"
        ) >> /etc/snips.toml
    fi
else
    bashio::log.info "Using default tts (picotts)"
fi

# Use Hass.io mqtt services
if MQTT_CONFIG="$(curl -s -f -H "X-Hassio-Key: ${HASSIO_TOKEN}" http://hassio/services/mqtt)"; then
    HOST="$(echo "${MQTT_CONFIG}" | jq --raw-output '.data.host')"
    PORT="$(echo "${MQTT_CONFIG}" | jq --raw-output '.data.port')"
    USER="$(echo "${MQTT_CONFIG}" | jq --raw-output '.data.username')"
    PASSWORD="$(echo "${MQTT_CONFIG}" | jq --raw-output '.data.password')"

    bashio::log.info "Setup Hass.io mqtt service to ${HOST}"

    (
        echo "connection main-mqtt"
        echo "address ${HOST}:${PORT}"
    ) >> /etc/mosquitto.conf

    if bashio::var.defined USER; then
      (
          echo "username ${USER}"
          echo "password ${PASSWORD}"
      ) >> /etc/mosquitto.conf
    fi

    (
        echo "topic hermes/intent/# out"
        echo "topic hermes/hotword/toggleOn out"
        echo "topic hermes/hotword/toggleOff out"
        echo "topic hermes/hotword/+/detected out"
        echo "topic hermes/asr/stopListening out"
        echo "topic hermes/asr/startListening out"
        echo "topic hermes/nlu/intentNotParsed out"
        echo "topic hermes/audioServer/+/playBytes/# out"
        echo "topic hermes/audioServer/+/playFinished out"
        echo "topic hermes/audioServer/+/playBytesStreaming/# out"
        echo "topic hermes/audioServer/+/streamFinished out"
        echo "topic # IN hermes/"
    ) >> /etc/mosquitto.conf
else
    bashio::log.error "No Hass.io mqtt service found!"
fi

bashio::log.info "Start internal mqtt broker"
mosquitto -c /etc/mosquitto.conf &


bashio::log.info "Checking for updated ${ASSISTANT} in /share"
# check if a new assistant file exists
if bashio::fs.file_exists "/share/${ASSISTANT}"; then
    bashio::log.info "Install/Update snips assistant"
    rm -rf /usr/share/snips/assistant
    unzip -o -u "/share/${ASSISTANT}" -d /usr/share/snips
# otherwise use the default
else
    bashio::log.info "Checking for /assistant_Hass_${LANG}.zip"
    if bashio::fs.file_exists "/assistant_Hass_${LANG}.zip"; then
        bashio::log.info "Using default assistant_Hass_${LANG}.zip"
        rm -rf /usr/share/snips/assistant
        unzip -o -u "/assistant_Hass_${LANG}.zip" -d /usr/share/snips
    else
        bashio::exit.nok "Could not find assistant!"
    fi
fi

bashio::log.info "Starting snips-watch"
( sleep 2; /usr/bin/snips-watch -vvv --no_color ) &

/usr/bin/snips-asr --version
/usr/bin/snips-injection --version
/usr/bin/snips-audio-server --version
/usr/bin/snips-dialogue --version
/usr/bin/snips-hotword --version
/usr/bin/snips-nlu --version

/snips-entrypoint.sh --mqtt localhost:1883
