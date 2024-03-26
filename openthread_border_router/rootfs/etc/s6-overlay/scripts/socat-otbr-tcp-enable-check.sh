#!/usr/bin/with-contenv bashio
# ==============================================================================
# Enable socat-otbr-tcp service if needed
# ==============================================================================

if bashio::config.has_value 'network_device'; then
    touch /etc/s6-overlay/s6-rc.d/user/contents.d/socat-otbr-tcp
    touch /etc/s6-overlay/s6-rc.d/otbr-agent/dependencies.d/socat-otbr-tcp
    bashio::log.info "Enabled socat-otbr-tcp."
fi
