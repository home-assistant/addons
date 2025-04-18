#!/usr/bin/with-contenv bashio
# shellcheck shell=bash
# ==============================================================================
# Configure OTBR depending on add-on settings
# ==============================================================================

if bashio::config.true 'otbr_nat64'; then
    bashio::log.info "Enabling NAT64."
    ot-ctl nat64 enable
    ot-ctl dns server upstream enable
fi

# To avoid asymmetric link quality the TX power from the controller should not
# exceed that of what other Thread routers devices typically use.
ot-ctl txpower 6
