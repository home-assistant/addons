#!/usr/bin/with-contenv bashio
# ==============================================================================
# Enable socat-cpcd-tcp service if needed
# ==============================================================================

if bashio::config.has_value 'bt_hci_enable'; then
    touch /etc/s6-overlay/s6-rc.d/user/contents.d/bt-hci
    bashio::log.info "Enabled bt-hci"
fi
