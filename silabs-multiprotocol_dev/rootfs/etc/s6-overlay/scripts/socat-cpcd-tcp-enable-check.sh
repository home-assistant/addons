#!/usr/bin/with-contenv bashio
# shellcheck shell=bash
# ==============================================================================
# Enable socat-cpcd-tcp service if needed
# ==============================================================================

if bashio::config.has_value 'network_device'; then
    touch /etc/s6-overlay/s6-rc.d/user/contents.d/socat-cpcd-tcp
    touch /etc/s6-overlay/s6-rc.d/cpcd/dependencies.d/socat-cpcd-tcp
    bashio::log.info "Enabled socat-cpcd-tcp."
fi
