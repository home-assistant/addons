#!/usr/bin/env bashio
set +u

CONFIG_PATH=/data/options.json
SYSTEM_USER=/data/system_user.json

LOGINS=$(jq --raw-output ".logins | length" $CONFIG_PATH)
ANONYMOUS=$(jq --raw-output ".anonymous" $CONFIG_PATH)
KEYFILE=$(jq --raw-output ".keyfile" $CONFIG_PATH)
CERTFILE=$(jq --raw-output ".certfile" $CONFIG_PATH)
CAFILE=$(jq --raw-output --exit-status ".cafile | select (.!=null)" $CONFIG_PATH || echo "$CERTFILE")
REQUIRE_CERTIFICATE=$(jq --raw-output ".require_certificate" $CONFIG_PATH)
CUSTOMIZE_ACTIVE=$(jq --raw-output ".customize.active" $CONFIG_PATH)
LOGGING=$(bashio::info 'hassio.info.logging' '.logging')
HOMEASSISTANT_PW=
ADDONS_PW=
WAIT_PIDS=()

SSL_CONFIG="
listener 8883
protocol mqtt
cafile /ssl/$CAFILE
certfile /ssl/$CERTFILE
keyfile /ssl/$KEYFILE
require_certificate $REQUIRE_CERTIFICATE

listener 8884
protocol websockets
cafile /ssl/$CAFILE
certfile /ssl/$CERTFILE
keyfile /ssl/$KEYFILE
require_certificate $REQUIRE_CERTIFICATE
"

function write_system_users() {
    (
        echo "{\"homeassistant\": {\"password\": \"$HOMEASSISTANT_PW\"}, \"addons\": {\"password\": \"$ADDONS_PW\"}}"
    ) > "${SYSTEM_USER}"
}

function call_hassio() {
    local method=$1
    local path=$2
    local data="${3}"
    local token=

    token="X-Hassio-Key: ${HASSIO_TOKEN}"
    url="http://hassio/${path}"

    # Call API
    if [ -n "${data}" ]; then
        curl -f -s -X "${method}" -d "${data}" -H "${token}" "${url}"
    else
        curl -f -s -X "${method}" -H "${token}" "${url}"
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
    echo "  \"protocol\": \"3.1.1\","
    echo "  \"username\": \"${user}\","
    echo "  \"password\": \"${password}\""
    echo "}"
}

function constrain_discovery() {
    local user=$1
    local password=$2
    local config=

    config="$(constrain_host_config "${user}" "${password}")"
    echo "{"
    echo "  \"service\": \"mqtt\","
    echo "  \"config\": ${config}"
    echo "}"
}

## Main ##

bashio::log.info "Setup mosquitto configuration"
sed -i "s/%%ANONYMOUS%%/$ANONYMOUS/g" /etc/mosquitto.conf

if [ "${LOGGING}" == "debug" ]; then
    sed -i "s/%%AUTH_QUIET_LOGS%%/false/g" /etc/mosquitto.conf
else
    sed -i "s/%%AUTH_QUIET_LOGS%%/true/g" /etc/mosquitto.conf
fi

# Enable SSL if exists configs
if [ -e "/ssl/$CAFILE" ] && [ -e "/ssl/$CERTFILE" ] && [ -e "/ssl/$KEYFILE" ]; then
    echo "$SSL_CONFIG" >> /etc/mosquitto.conf
else
    bashio::log.warning "SSL not enabled - No valid certs found!"
fi

# Allow customize configs from share
if [ "$CUSTOMIZE_ACTIVE" == "true" ]; then
    CUSTOMIZE_FOLDER=$(jq --raw-output ".customize.folder" $CONFIG_PATH)
    sed -i "s|#include_dir .*|include_dir /share/$CUSTOMIZE_FOLDER|g" /etc/mosquitto.conf
fi

# Handle local users
if [ "$LOGINS" -gt "0" ]; then
    bashio::log.info "Found local users inside config"
else
    bashio::log.info "No local user available"
fi

# Prepare System Accounts
if [ ! -e "${SYSTEM_USER}" ]; then
    HOMEASSISTANT_PW="$(pwgen 64 1)"
    ADDONS_PW="$(pwgen 64 1)"

    bashio::log.info "Initialize system configuration."
    write_system_users
else
    HOMEASSISTANT_PW=$(jq --raw-output '.homeassistant.password' $SYSTEM_USER)
    ADDONS_PW=$(jq --raw-output '.addons.password' $SYSTEM_USER)
fi

# Initial Service
if call_hassio GET "services/mqtt" | jq --raw-output ".data.host" | grep -v "$(hostname)" > /dev/null; then
    bashio::log.warning "There is already an MQTT service running!"
else
    bashio::log.info "Initialize Home Assistant Add-on services"
    if ! call_hassio POST "services/mqtt" "$(constrain_host_config addons "${ADDONS_PW}")" > /dev/null; then
        bashio::log.error "Can't setup Home Assistant service mqtt"
    fi

    bashio::log.info "Initialize Home Assistant discovery"
    if ! call_hassio POST "discovery" "$(constrain_discovery homeassistant "${HOMEASSISTANT_PW}")" > /dev/null; then
        bashio::log.error "Can't setup Home Assistant discovery mqtt"
    fi
fi

bashio::log.info "Start Mosquitto daemon"

# Start Auth Server
socat TCP-LISTEN:8080,fork,reuseaddr SYSTEM:/bin/auth_srv.sh &
WAIT_PIDS+=($!)

# Start Mosquitto Server
mosquitto -c /etc/mosquitto.conf &
WAIT_PIDS+=($!)

# Handling Closing
function stop_mqtt() {
    bashio::log.info "Shutdown mqtt system"
    kill -15 "${WAIT_PIDS[@]}"

    # Remove service
    if call_hassio GET "services/mqtt" | jq --raw-output ".data.host" | grep "$(hostname)" > /dev/null; then
        if ! call_hassio DELETE "services/mqtt"; then
            bashio::log.warning "Service unregister fails!"
        fi
    fi

    wait "${WAIT_PIDS[@]}"
}
trap "stop_mqtt" SIGTERM SIGHUP

# Wait and hold Add-on running
wait "${WAIT_PIDS[@]}"
