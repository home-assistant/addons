#!/usr/bin/with-contenv bashio
# ==============================================================================
# Configure OTBR depending on add-on settings
# ==============================================================================

#if bashio::config.true 'nat64'; then
    ot-ctl nat64 enable
    bashio::log.info "NAT64 enabled."
#fi
