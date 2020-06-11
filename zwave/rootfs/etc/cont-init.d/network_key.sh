#!/usr/bin/with-contenv bashio
# ==============================================================================
# Check to see if example network key from documentation is used
# ==============================================================================
readonly DOCS_EXAMPLE_KEY="0x2e, 0xcc, 0xab, 0x1c, 0xa3, 0x7f, 0x0e, 0xb5, 0x70, 0x71, 0x2d, 0x98, 0x25, 0x43, 0xee, 0x0c"

if [[ "${DOCS_EXAMPLE_KEY}" == "$(bashio::config 'network_key')" ]]; then
    bashio::exit.nok "Network key from the example documentation used. Please create an unique one!"
fi
