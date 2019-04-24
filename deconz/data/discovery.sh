#!/usr/bin/env bashio

DATA_STORE="/data/hassio.json"


function _discovery_config() {
    local api_key=${1}
    local serial=${2}
    local config

    config=$(bashio::var.json \
        host "$(bashio::addon.ip_address)" \
        port "^$(bashio::addon.port 80)" \
        api_key "${api_key}" \
        serial "${serial}" \
    )

    bashio::var.json \
            service deconz \
            config "^${config}"
}


function _save_data() {
    local api_key=${1}
    local serial=${2}
    local config

    bashio::var.json api_key "${api_key}" serial "${serial}" > ${DATA_STORE}
    bashio::log.debug "Store API information to ${DATA_STORE}"
}


function _deconz_api() {
    local api_key
    local result
    local api_port

    api_port=$(bashio::addon.port 80)
    while ! nc -z localhost "${api_port}" < /dev/null; do sleep 10; done

    if ! result="$(curl --silent --show-error --request POST -d '{"devicetype": "Home Assistant"}' "http://127.0.0.1:${api_port}/api")"; then
        bashio::log.debug "${result}"
        bashio::exit.nok "Can't get API key from deCONZ gateway"
    fi
    api_key="$(echo "${result}" | jq --raw-output '.[0].success.username')"

    sleep 15
    if ! result="$(curl --silent --show-error --request GET "http://127.0.0.1:${api_port}/api/${api_key}/config")"; then
        bashio::log.debug "${result}"
        bashio::exit.nok "Can't get data from deCONZ gateway"
    fi
    serial="$(echo "${result}" | jq --raw-output '.bridgeid')"

    _save_data "${api_key}" "${serial}"
}


function _send_discovery() {
    local api_key
    local result
    local payload

    api_key="$(jq --raw-output '.api_key' "${DATA_STORE}")"
    serial="$(jq --raw-output '.serial' "${DATA_STORE}")"

    # Send discovery info
    payload="$(_discovery_config "${api_key}" "${serial}")"
    if bashio::api.hassio "POST" "/discovery" "${payload}"; then
        bashio::log.info "Success send discovery information to Home Assistant"
    else
        bashio::log.error "Discovery message to Home Assistant fails!"
    fi
}


function hassio_discovery() {

    # No API data exists - generate
    if [ ! -f "$DATA_STORE" ]; then
        bashio::log.info "Create API data for Home Assistant"
        _deconz_api
    fi

    _send_discovery
}
