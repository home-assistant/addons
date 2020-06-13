#!/usr/bin/with-contenv bashio
# ==============================================================================
# Check to see if example network key from documentation is used
# ==============================================================================
readonly DOCS_EXAMPLE_KEY="0xB4, 0xE6, 0xF9, 0x35, 0x4F, 0xE0, 0x73, 0xCB, 0xBA, 0xC0, 0x53, 0x66, 0x90, 0xA6, 0x90, 0x13"

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
