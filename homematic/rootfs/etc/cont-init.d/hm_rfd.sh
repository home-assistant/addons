#!/usr/bin/with-contenv bashio
# ==============================================================================
# Update HomeMatic firmware
# ==============================================================================

# RF support
if bashio::config.false 'rf_enable'; then
    bashio::exit.ok
fi
bashio::log.info "Setup BidCos-RF"

# Generate config
tempio \
    -conf /data/options.json \
    -template /usr/share/tempio/rfd.conf \
    -out /etc/config/rfd.conf

# Init GPIO
if [ ! -d /sys/class/gpio/gpio18 ]; then
    echo 18 > /sys/class/gpio/export
    sleep 2
fi
if [ "$(cat /sys/class/gpio/gpio18/direction)" != "out" ]; then
    echo out > /sys/class/gpio/gpio18/direction
    sleep 2
fi

echo 0 > /sys/class/gpio/gpio18/value || echo "Can't set default value!"
sleep 0.5

# Update Firmware
if "${HM_HOME}/bin/eq3configcmd" update-coprocessor -lgw -u -rfdconf /etc/config/rfd.conf -l 1; then
    bashio::log.info "RFd update was successful"
else
    bashio::log.error "RFd update fails!"
fi
