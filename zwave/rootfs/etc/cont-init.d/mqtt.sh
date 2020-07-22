#!/usr/bin/with-contenv bashio
# ==============================================================================
# Setup MQTT settings
# ==============================================================================
declare host
declare ozw_instance
declare ozw_status
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

    bashio::log.info "Connect to internal MQTT service"

    if bashio::config.has_value 'instance'; then
        ozw_instance=$(bashio::config 'instance')
    else
        ozw_instance=1
    fi

    # Ensure upstream MQTT server has the right OZW status
    # Workaround for an incorrect retained OZW status in MQTT
    # In this case, the LWT is not relayed to the upstream MQTT server.
    # https://github.com/home-assistant/hassio-addons/issues/1462
    ozw_status=$(\
        mosquitto_sub \
            --host "${host}" \
            --port "${port}" \
            --username "${username}" \
            --pw "${password}" \
            -C 1 \
            -W 3 \
            --retained-only \
            --topic "OpenZWave/${ozw_instance}/status/" \
    )
    if bashio::var.has_value "${ozw_status}" \
        && [[ $(bashio::jq "${ozw_status}" ".Status") != "Offline" ]];
    then
        mosquitto_pub \
            --host "${host}" \
            --port "${port}" \
            --username "${username}" \
            --pw "${password}" \
            --retain \
            --topic "OpenZWave/${ozw_instance}/status/" \
            --message "$(bashio::var.json "Status" "Offline")"
    fi
fi
