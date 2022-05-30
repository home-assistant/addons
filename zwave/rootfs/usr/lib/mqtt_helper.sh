#!/usr/bin/with-contenv bashio
# ==============================================================================
# MQTT helpers for the zwave add-on.
# ==============================================================================

# ------------------------------------------------------------------------------
# Ensure upstream MQTT server has the correct OZW status retained on shutdown.
#
# Arguments:
#   $1 MQTT Server host
#   $2 MQTT Server port
#   $3 MQTT Server username
#   $4 MQTT Server password
#   $5 OZW Instance ID (optional)
# ------------------------------------------------------------------------------
function mqtt::ensure_ozw_offline_status() {
    local host=${1}
    local port=${2}
    local username=${3}
    local password=${4}
    local ozw_instance=${5:-}
    local ozw_status

    bashio::log.trace "${FUNCNAME[0]}:" "$@"

    if ! bashio::var.has_value "${ozw_instance}"; then
        ozw_instance=1
        if bashio::config.has_value 'instance'; then
            ozw_instance=$(bashio::config 'instance')
        fi
    fi

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
}
