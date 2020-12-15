#!/usr/bin/with-contenv bashio
# ==============================================================================
# Update HomeMatic firmware
# ==============================================================================
# shellcheck disable=SC2012
declare hmip_index
declare hmip_type
declare hmip_device
declare hmip_adapter
declare version_to
declare version_from

# HMIP support
if bashio::config.false 'hmip_enable'; then
    bashio::exit.ok
fi
bashio::log.info "Setup HmIP-RF"

# Restore data
if [ -f /data/hmip_address.conf ]; then
    cp -f /data/hmip_address.conf /etc/config/
fi

# Setup settings
for hmip_index in $(bashio::config 'hmip|keys'); do
    hmip_type=$(bashio::config "hmip[${hmip_index}].type")
    hmip_device=$(bashio::config "hmip[${hmip_index}].device")
    hmip_adapter=$((hmip_index+1))

    # Update Firmware
    version_from="$(java -Xmx64m -jar /opt/HmIP/hmip-copro-update.jar -p "${hmip_device}" -v | grep "Application version =" | cut -d' ' -f5)"
    version_to="$(ls /firmware/HmIP-RFUSB/hmip_coprocessor_update-*.eq3 | sed 's/.*hmip_coprocessor_update-\(.*\)\.eq3/\1/' | tail -n1)"
    if [ "${version_from}" != "${version_to}" ]; then
        if java -Xmx64m -jar /opt/HmIP/hmip-copro-update.jar -p "${hmip_device}" -f "/firmware/HmIP-RFUSB/hmip_coprocessor_update-${version_to}.eq3"; then
            bashio::log.info "HmIP update to ${version_to} was successful"
        else
            bashio::log.error "HmIP update ${version_to} fails!"
        fi
    fi

    # Update config
    (
        echo "Adapter.${hmip_adapter}.Type=${hmip_type}"
        echo "Adapter.${hmip_adapter}.Port=${hmip_device}"
    ) >> /etc/config/crRFD.conf
done
