#!/usr/bin/with-contenv bashio
# shellcheck shell=bash
set -e

CONFIG="/etc/tellstick.conf"

bashio::log.info "Initialize the tellstick configuration..."
# User access
{
    echo "user = \"root\""
    echo "group = \"plugdev\""
    echo "ignoreControllerConfirmation = \"false\"" 
} > "${CONFIG}"

# devices
for device in $(bashio::config 'devices|keys'); do
    DEV_ID=$(bashio::config "devices[${device}].id")
    DEV_NAME=$(bashio::config "devices[${device}].name")
    DEV_PROTO=$(bashio::config "devices[${device}].protocol")
    DEV_MODEL=$(bashio::config "devices[${device}].model")
    ATTR_HOUSE=$(bashio::config "devices[${device}].house")
    ATTR_CODE=$(bashio::config "devices[${device}].code")
    ATTR_UNIT=$(bashio::config "devices[${device}].unit")
    ATTR_FADE=$(bashio::config "devices[${device}].fade")
  
    (
        echo ""
        echo "device {"
        echo "  id = ${DEV_ID}"
        echo "  name = \"${DEV_NAME}\""
        echo "  protocol = \"${DEV_PROTO}\""
        
        bashio::var.has_value "${DEV_MODEL}" \
            && echo "  model = \"${DEV_MODEL}\""
        
        if bashio::var.has_value "${ATTR_HOUSE}${ATTR_CODE}${ATTR_UNIT}${ATTR_FADE}";
        then
            echo "  parameters {"

            bashio::var.has_value "${ATTR_HOUSE}" \
                && echo "    house = \"${ATTR_HOUSE}\""

            bashio::var.has_value "${ATTR_CODE}" \
                && echo "    code = \"${ATTR_CODE}\""

            bashio::var.has_value "${ATTR_UNIT}" \
                && echo "    unit = \"${ATTR_UNIT}\""

            bashio::var.has_value "${ATTR_FADE}" \
                && echo "    fade = \"${ATTR_FADE}\""
            
            echo "  }"
        fi
        
        echo "}"
    ) >> "${CONFIG}"
done

bashio::log.info "Exposing sockets and loading service..."

# Expose the unix socket to internal network
socat TCP-LISTEN:50800,reuseaddr,fork UNIX-CONNECT:/tmp/TelldusClient &
socat TCP-LISTEN:50801,reuseaddr,fork UNIX-CONNECT:/tmp/TelldusEvents &

# Run telldus-core daemon in the background
/usr/local/sbin/telldusd --nodaemon < /dev/null &

# Listen for input to tdtool
bashio::log.info "Starting event listener..."
while read -r input; do
    # parse JSON value
    funct=$(bashio::jq "${input}" '.function')
    devid=$(bashio::jq "${input}" '.device // empty')
    bashio::log.info "Read ${funct} / ${devid}"

    if ! msg="$(tdtool "--${funct}" "${devid}")"; then
        bashio::log.error "TellStick ${funct} fails -> ${msg}"
    else
        bashio::log.info "TellStick ${funct} success -> ${msg}"
    fi
done
