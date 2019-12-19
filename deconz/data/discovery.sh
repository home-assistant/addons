#!/usr/bin/env bashio

DATA_STORE="/data/hassio.json"


function _deconz_api() {
    local api_key
    local result
    local serial

    # Register an API key for Home Assistant
    if ! result="$(curl --silent --show-error --request POST -d '{"devicetype": "Home Assistant"}' "http://127.0.0.1:8080/api")"; then
        bashio::log.debug "${result}"
        bashio::exit.nok "Can't get API key from deCONZ gateway"
    fi
    api_key="$(bashio::jq "${result}" '.[0].success.username')"

    # Try to get the bridge ID/serial, try to avoid using 0000000000000000
    retries=25
    serial="0000000000000000"
    while [[ "${serial}" = "0000000000000000" ]]; do
        bashio::log.debug "Waiting for bridge ID..."
        sleep 10

        # If we tried 25 times, just abort.
        if [[ "${retries}" -eq 0 ]]; then
            bashio::exit.nok "Failed to get a valid bridge ID. Discovery aborted."
        fi

        # Get bridge ID from API
        if ! result="$(curl --silent --show-error --request GET "http://127.0.0.1:8080/api/${api_key}/config")";
        then
            bashio::log.debug "${result}"
            bashio::exit.nok "Can't get data from deCONZ gateway"
        fi
        serial="$(bashio::jq "${result}" '.bridgeid')"

        ((retries--))
    done

    bashio::var.json api_key "${api_key}" serial "${serial}" > "${DATA_STORE}"
    bashio::log.debug "Stored API information to ${DATA_STORE}"
}


function _send_discovery() {
    local api_key
    local config
    local result

    api_key="$(bashio::jq "${DATA_STORE}" '.api_key')"
    serial="$(bashio::jq "${DATA_STORE}" '.serial')"

    config=$(bashio::var.json \
        host "$(hostname)" \
        port "^8080" \
        api_key "${api_key}" \
        serial "${serial}" \
    )

    # Send discovery info
    if bashio::discovery "deconz" "${config}" > /dev/null; then
        bashio::log.info "Successfully send discovery information to Home Assistant."
    else
        bashio::log.error "Discovery message to Home Assistant failed!"
    fi
}


function hassio_discovery() {

    # No API data exists - generate
    if ! bashio::fs.file_exists "${DATA_STORE}"; then
        bashio::log.info "Create API data for Home Assistant"
        _deconz_api
    fi

    _send_discovery
}
