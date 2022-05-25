#!/usr/bin/with-contenv bashio
# ==============================================================================
# Setup MQTT settings
# ==============================================================================
# shellcheck disable=SC1091
source /usr/lib/mqtt_helper.sh

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
        echo "remote_clientid zwave"
        echo "local_clientid zwave"
        echo "cleansession true"
        echo "notifications true"
        echo "try_private true"
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

    # Ensure upstream MQTT server has the right OZW status
    # Workaround for an incorrect retained OZW status in MQTT
    # In this case, the LWT is not relayed to the upstream MQTT server.
    # https://github.com/home-assistant/hassio-addons/issues/1462
    mqtt::ensure_ozw_offline_status \
        "${host}" "${port}" "${username}" "${password}"


    bashio::log.info "Connected to internal MQTT service"
fi
