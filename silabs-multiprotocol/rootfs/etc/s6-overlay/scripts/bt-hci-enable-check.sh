#!/usr/bin/with-contenv bashio
# ==============================================================================
# Enable bt-hci service if needed
# ==============================================================================

if bashio::config.true 'bt_hci_enable'; then
    touch /etc/s6-overlay/s6-rc.d/user/contents.d/bt-hci
    bashio::log.info "Enabled bt-hci"
fi
