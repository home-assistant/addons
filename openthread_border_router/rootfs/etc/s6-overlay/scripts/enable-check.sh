#!/usr/bin/with-contenv bashio
# ==============================================================================
# Disable OTBR Web if necessary ports are not exposed
# ==============================================================================

if bashio::var.has_value "$(bashio::addon.port 8080)" \
     && bashio::var.has_value "$(bashio::addon.port 8081)"; then
    bashio::log.info "Web UI and REST API port are exposed, starting otbr-web."
else
    rm /etc/s6-overlay/s6-rc.d/user/contents.d/otbr-web
    bashio::log.info "The otbr-web is disabled."
fi

# ==============================================================================
# Enable socat-otbr-tcp service if needed
# ==============================================================================

if bashio::config.has_value 'network_device'; then
    touch /etc/s6-overlay/s6-rc.d/user/contents.d/socat-otbr-tcp
    touch /etc/s6-overlay/s6-rc.d/otbr-agent/dependencies.d/socat-otbr-tcp
    bashio::log.info "Enabled socat-otbr-tcp."
fi
