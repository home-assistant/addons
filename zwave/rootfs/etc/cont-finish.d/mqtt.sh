#!/usr/bin/with-contenv bashio
# ==============================================================================
# Ensure upstream MQTT server has the correct OZW status retained on shutdown.
# ==============================================================================
# shellcheck disable=SC1091
source /usr/lib/mqtt_helper.sh

declare host
declare password
declare port
declare username

if bashio::services.available "mqtt"; then
    bashio::log.info "Ensure upstream MQTT server has the correct OZW status"
    host=$(bashio::services "mqtt" "host")
    password=$(bashio::services "mqtt" "password")
    port=$(bashio::services "mqtt" "port")
    username=$(bashio::services "mqtt" "username")

    mqtt::ensure_ozw_offline_status \
        "${host}" "${port}" "${username}" "${password}"
fi
