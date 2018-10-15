#!/bin/bash
set -e

CONFIG_PATH=/data/options.json
SYSTEM_USER=/data/system_user.json

LOGINS=$(jq --raw-output ".logins | length" $CONFIG_PATH)
KEYFILE=$(jq --raw-output ".keyfile" $CONFIG_PATH)
CERTFILE=$(jq --raw-output ".certfile" $CONFIG_PATH)
CUSTOMIZE_ACTIVE=$(jq --raw-output ".customize.active" $CONFIG_PATH)
HOMEASSISTANT_PW=""
ADDONS_PW=""
PID_MOSQUITTO=0
PID_SOCAT=0

SSL_CONFIG="
listener 8883
protocol mqtt
cafile /ssl/$CERTFILE
certfile /ssl/$CERTFILE
keyfile /ssl/$KEYFILE

listener 8884
protocol websockets
cafile /ssl/$CERTFILE
certfile /ssl/$CERTFILE
keyfile /ssl/$KEYFILE
"

# Enable SSL if exists configs
if [ -e "/ssl/$CERTFILE" ] && [ -e "/ssl/$KEYFILE" ]; then
    echo "$SSL_CONFIG" >> /etc/mosquitto.conf
else
    echo "[Warning] SSL not enabled - No valid certs found!"
fi

# Allow customize configs from share
if [ "$CUSTOMIZE_ACTIVE" == "true" ]; then
    CUSTOMIZE_FOLDER=$(jq --raw-output ".customize.folder" $CONFIG_PATH)
    sed -i "s|#include_dir .*|include_dir /share/$CUSTOMIZE_FOLDER|g" /etc/mosquitto.conf
fi

# Prepare System Accounts
if [ ! -e "${SYSTEM_USER}" ]; then
    HOMEASSISTANT_PW="$(/dev/urandom tr -dc _A-Z-a-z-0-9 | head -c32)"
    ADDONS_PW="$(/dev/urandom tr -dc _A-Z-a-z-0-9 | head -c32)"

    echo "{\"homeassistant\": {\"password\": \"$HOMEASSISTANT_PW\"}, \"addons\": {\"password\": \"$ADDONS_PW\"}}" > "${SYSTEM_USER}"
else
    HOMEASSISTANT_PW=$(jq --raw-output '.homeassistant.password' $SYSTEM_USER)
    ADDONS_PW=$(jq --raw-output '.addons.password' $SYSTEM_USER)
fi

# Start Auth Server
socat TCP-LISTEN:9123,fork,reuseaddr EXEC:/bin/auth_srv.sh &
PID_SOCAT=$1

# Start Mosquitto Server
mosquitto -c /etc/mosquitto.conf &
PID_MOSQUITTO=$!

# Handling Closing
function stop_mqtt() {
    echo "[Info] Shutdown mqtt system"
    kill -15 ${PID_MOSQUITTO}
    kill -15 ${PID_SOCAT}

    curl -X DELETE -H "X-Hassio-Key: ${HASSIO_TOKEN}" http://hassio/services/mqtt
}
trap "stop_mqtt" SIGTERM SIGHUP

# Wait and hold Add-on running
wait "${PID_SOCAT}" "${PID_MOSQUITTO}"
