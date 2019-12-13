#!/usr/bin/env bashio
set +u

SYSTEM_USER=/data/system_user.json

LOGINS=$(bashio::config "logins | length")
ANONYMOUS=$(bashio::config "anonymous")
KEYFILE=$(bashio::config "keyfile")
CERTFILE=$(bashio::config "certfile")
CAFILE=$(bashio::config "cafile | select (.!=null)" || echo "$CERTFILE")
REQUIRE_CERTIFICATE=$(bashio::config "require_certificate")
CUSTOMIZE_ACTIVE=$(bashio::config "customize.active")
LOGGING=$(bashio::info "hassio.info.logging" ".logging")
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
    if bashio::var.has_value "${data}"; then
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

if bashio::var.equals "${LOGGING}" "debug"; then
    sed -i "s/%%AUTH_QUIET_LOGS%%/false/g" /etc/mosquitto.conf
else
    sed -i "s/%%AUTH_QUIET_LOGS%%/true/g" /etc/mosquitto.conf
fi

# Enable SSL if exists configs
if bashio::fs.file_exists "/ssl/$CAFILE" &&
   bashio::fs.file_exists "/ssl/$CERTFILE" &&
   bashio::fs.file_exists "/ssl/$KEYFILE"; then
    echo "$SSL_CONFIG" >> /etc/mosquitto.conf
else
    bashio::log.warning "SSL not enabled - No valid certs found!"
fi

# Allow customize configs from share
if bashio::var.true "${CUSTOMIZE_ACTIVE}"; then
    CUSTOMIZE_FOLDER=$(bashio::config ".customize.folder")
    sed -i "s|#include_dir .*|include_dir /share/$CUSTOMIZE_FOLDER|g" /etc/mosquitto.conf
fi

# Handle local users
if [ "$LOGINS" -gt "0" ]; then
    bashio::log.info "Found local users inside config"
else
    bashio::log.info "No local user available"
fi

# Prepare System Accounts
if bashio::fs.file_exists "${SYSTEM_USER}"; then
    HOMEASSISTANT_PW=$(bashio::jq "${SYSTEM_USER}" '.homeassistant.password')
    ADDONS_PW=$(bashio::jq "${SYSTEM_USER}" '.addons.password')
else
    HOMEASSISTANT_PW="$(pwgen 64 1)"
    ADDONS_PW="$(pwgen 64 1)"

    bashio::log.info "Initialize system configuration."
    write_system_users
fi

# Initial Service
if call_hassio GET "services/mqtt" | jq --raw-output ".data.host" | grep -v "$(hostname)" > /dev/null; then
    bashio::log.warning "There is allready a MQTT services running!"
else
    bashio::log.info "Initialize Hass.io Add-on services"
    if ! call_hassio POST "services/mqtt" "$(constrain_host_config addons "${ADDONS_PW}")" > /dev/null; then
        bashio::log.error "Can't setup Hass.io service mqtt"
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
