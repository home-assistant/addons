#!/usr/bin/with-contenv bashio
# ==============================================================================
# Update HomeMatic firmware
# ==============================================================================
# shellcheck disable=SC2012
declare rf_index
declare rf_type
declare rf_device

# RF support
if bashio::config.false 'rf_enable'; then
    bashio::exit.ok
fi
bashio::log.info "Setup BidCos-RF"

for rf_index in $(bashio::config 'rf|keys'); do
    rf_type=$(bashio::config "rf[${rf_index}].type")

    # Update config
    if [ "${rf_type}" == "CCU2" ]; then
        rf_device=$(bashio::config "rf[${rf_index}].device")
        (
            echo "[Interface $1]"
            echo "Type = CCU2"
            echo "ComPortFile = ${rf_device}"
            echo "AccessFile = /dev/null"
            echo "ResetFile = /sys/class/gpio/gpio18/value"
        ) >> /etc/config/rfd.conf

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
    fi
done

# Update Firmware
if "${HM_HOME}/bin/eq3configcmd" update-coprocessor -lgw -u -rfdconf /etc/config/rfd.conf -l 1; then
    bashio::log.info "RFd update was successful"
else
    bashio::log.error "RFd update fails!"
fi
