#!/usr/bin/with-contenv bashio
# ==============================================================================
# Ensure upstream MQTT server has the correct OZW status retained on shutdown.
# ==============================================================================
declare host
declare ozw_instance
declare ozw_status
declare password
declare port
declare username

if bashio::services.available "mqtt"; then
    bashio::log.info "Ensure upstream MQTT server has the correct OZW status"
    host=$(bashio::services "mqtt" "host")
    password=$(bashio::services "mqtt" "password")
    port=$(bashio::services "mqtt" "port")
    username=$(bashio::services "mqtt" "username")

    if bashio::config.has_value 'instance'; then
        ozw_instance=$(bashio::config 'instance')
    else
        ozw_instance=1
    fi

    # Ensure upstream MQTT server has the right OZW status on shutdown
    # In this case, the LTW is no relayed to the upstream MQTT server
    # Workaround for an incorrect retained OZW status in MQTT
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
