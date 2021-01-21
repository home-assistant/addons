#!/usr/bin/with-contenv bashio
# ==============================================================================
# Update HomeMatic firmware
# ==============================================================================

# Wired support
if bashio::config.false 'wired_enable'; then
    bashio::exit.ok
fi
bashio::log.info "Setup Hm-Wired"

# Generate config
tempio \
    -conf /data/options.json \
    -template /usr/share/tempio/hs485d.conf \
    -out /etc/config/hs485d.conf

# Update Firmware
if "${HM_HOME}/bin/eq3configcmd" update-lgw-firmware -m /firmware/fwmap -c /etc/config/hs485d.conf -l 1; then
    bashio::log.info "Wired update was successful"
else
    bashio::log.error "Wired update fails!"
fi
