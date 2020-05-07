#!/usr/bin/with-contenv bashio
# ==============================================================================
# Setup mqtt settings
# ==============================================================================
declare host
declare password
declare port
declare username

if ! bashio::services.available "mqtt"; then
    bashio::log.info "No internal MqTT service found"
else
    host=$(bashio::services "mqtt" "host")
    password=$(bashio::services "mqtt" "password")
    port=$(bashio::services "mqtt" "port")
    username=$(bashio::services "mqtt" "username")

    (
        echo "connection main-mqtt"
        echo "address ${host}:${port}"
    ) >> /etc/mosquitto.conf

    # Need auth?
    if bashio::var.has_value "${username}" && bashio::var.has_value "${password}"; then
        (
            echo "username ${username}"
            echo "password ${password}"
        ) >> /etc/mosquitto.conf
    fi

    (
        echo "topic OpenZWave/# out"
        echo "topic # IN OpenZWave/"
    ) >> /etc/mosquitto.conf

    bashio::log.info "Connect to internal MqTT service"
fi
