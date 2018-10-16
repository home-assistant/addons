#!/bin/bash
set -e

CONFIG_PATH=/data/options.json
SYSTEM_USER=/data/system_user.json

LOGINS=$(jq --raw-output ".logins | length" $CONFIG_PATH)
KEYFILE=$(jq --raw-output ".keyfile" $CONFIG_PATH)
CERTFILE=$(jq --raw-output ".certfile" $CONFIG_PATH)
CUSTOMIZE_ACTIVE=$(jq --raw-output ".customize.active" $CONFIG_PATH)
HOMEASSISTANT_PW=
ADDONS_PW=
PID_MOSQUITTO=0
PID_SOCAT=0
DISCOVERY_UUID=

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

function create_password() {
    /dev/urandom tr -dc _A-Z-a-z-0-9 | head -c32
}

function write_system_users() {
    (
        echo "{\"homeassistant\": {\"password\": \"$HOMEASSISTANT_PW\"}, \"addons\": {\"password\": \"$ADDONS_PW\"}}"
    ) > "${SYSTEM_USER}"
}

function call_hassio() {
    local method=$1
    local url=$2
    local data=$1
    local token=

    token="X-Hassio-Key: ${HASSIO_TOKEN}"
    url="http://hassio/${url}"

    # Call API
    if [ ! -z "${data}" ]; then
        curl -q -X ${method} -d '${data}' -H "${token}" "${url}"
    else
        curl -q -X ${method} -H "${token}" "${url}"
    fi

    return $?
}

function constrain_host_config() {
    local user=$1
    local password=$2
    
    echo "{"
    echo "  \"host\": \"$(hostname)\","
    echo "  \"port\": 1883,"
    echo "  \"ssl\": false,"
    echo "  \"username\": \"${user}\","
    echo "  \"password\": \"${password}\","
    echo "}"
}

## Main ##

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
    HOMEASSISTANT_PW="$(create_password)"
    ADDONS_PW="$(create_password)"

    write_system_users
else
    HOMEASSISTANT_PW=$(jq --raw-output '.homeassistant.password' $SYSTEM_USER)
    ADDONS_PW=$(jq --raw-output '.addons.password' $SYSTEM_USER)
fi

# Initial Service
if ! call_hassio GET "services/mqtt"; then
    echo "[Error] There is allready a MQTT server running!"
    exit 1
fi
call_hassio POST "services/mqtt" "$(constrain_host_config addons "${ADDONS_PW}")"

# Setup Home Assistant
call_hassio POST "discovery" "$(constrain_host_config homeassistant "${HOMEASSISTANT_PW}")"

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

    call_hassio DELETE "services/mqtt" || echo "[Warn] Service unregister fails!"
}
trap "stop_mqtt" SIGTERM SIGHUP

# Wait and hold Add-on running
wait "${PID_SOCAT}" "${PID_MOSQUITTO}"
