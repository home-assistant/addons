#!/usr/bin/with-contenv bashio
# ==============================================================================
# Configure OTBR depending on add-on settings
# ==============================================================================

if bashio::config.true 'nat64'; then
    bashio::log.info "Enabling NAT64."
    ot-ctl nat64 enable
fi

# Set higher transmit power
ot-ctl txpower 6
