#!/usr/bin/with-contenv bashio
# ==============================================================================
# Check to see if example network key from documentation is used
# ==============================================================================
readonly DOCS_EXAMPLE_KEY="0x2e, 0xcc, 0xab, 0x1c, 0xa3, 0x7f, 0x0e, 0xb5, 0x70, 0x71, 0x2d, 0x98, 0x25, 0x43, 0xee, 0x0c"

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
    bashio::log.fatal 'Click on the "Documentation" tab in the OpenZWave'
    bashio::log.fatal 'add-on panel for more information.'
    bashio::log.fatal
    bashio::exit.nok
fi
