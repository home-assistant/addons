#!/usr/bin/with-contenv bashio
# shellcheck shell=bash
# ==============================================================================
# Configure OTBR depending on add-on settings
# ==============================================================================

ot-ctl trel enable

if bashio::config.true 'nat64'; then
    bashio::log.info "Enabling NAT64."
    ot-ctl nat64 enable
    ot-ctl dns server upstream enable
fi

if bashio::config.true 'beta'; then
    mdns_localhostname="$(hostname)-br"
    bashio::log.info "Setting OpenThread mDNS local hostname to ${mdns_localhostname}."
    ot-ctl mdns localhostname "${mdns_localhostname}"
    ot-ctl mdns enable
fi

# To avoid asymmetric link quality the TX power from the controller should not
# exceed that of what other Thread routers devices typically use.
ot-ctl txpower 6
