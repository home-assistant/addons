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

mdns_localhostname="$(hostname)-otbr"
bashio::log.info "Setting OpenThread mDNS local hostname to ${mdns_localhostname}."
ot-ctl mdns localhostname "${mdns_localhostname}"
ot-ctl mdns enable

# To avoid asymmetric link quality the TX power from the controller should not
# exceed that of what other Thread routers devices typically use.
tx_power=6
if bashio::config.has_value 'tx_power'; then
    tx_power="$(bashio::config 'tx_power')"
    bashio::log.info "Setting Thread radio TX power to ${tx_power} dBm."
fi
ot-ctl txpower "${tx_power}"
