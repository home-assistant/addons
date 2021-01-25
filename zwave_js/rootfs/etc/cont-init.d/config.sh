#!/usr/bin/with-contenv bashio
# ==============================================================================
# Generate Z-Wave JS config file
# ==============================================================================
declare network_key

readonly DOCS_EXAMPLE_KEY="2232666D100F795E5BB17F0A1BB7A146"

if [[ "${DOCS_EXAMPLE_KEY}" == "$(bashio::config 'network_key')" ]]; then
    bashio::log.fatal
    bashio::log.fatal 'The add-on detected that the Z-Wave network key used'
    bashio::log.fatal 'is from the documented example.'
    bashio::log.fatal
    bashio::log.fatal 'Using this key is insecure, because it is publicly'
    bashio::log.fatal 'listed in the documentation.'
    bashio::log.fatal
    bashio::log.fatal 'Please check the add-on documentation on how to'
    bashio::log.fatal 'create your own, secret, "network_key" and replace'
    bashio::log.fatal 'the one you have configured.'
    bashio::log.fatal
    bashio::log.fatal 'Click on the "Documentation" tab in the Z-Wave JS'
    bashio::log.fatal 'add-on panel for more information.'
    bashio::log.fatal
    bashio::exit.nok
elif ! bashio::config.has_value 'network_key'; then
    bashio::log.info "No Network Key is set, generate one..."
    network_key=$(hexdump -n 16 -e '4/4 "%08X" 1 "\n"' /dev/random)
    bashio::addon.option network_key "${network_key}"
else
    network_key=$(bashio::config 'network_key')
fi


# Generate config
bashio::var.json \
    network_key "${network_key}" \
    logging "$(bashio::info.logging)" \
    | tempio \
        -template /usr/share/tempio/zwave_config.conf \
        -out /etc/zwave_config.json
