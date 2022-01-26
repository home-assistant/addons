#!/usr/bin/with-contenv bashio
# ==============================================================================
# Update HomeMatic firmware
# ==============================================================================
# shellcheck disable=SC2012
#declare hmip_index
#declare hmip_device
#declare version_to
#declare version_from

# HMIP support
if bashio::config.false 'hmip_enable'; then
    bashio::exit.ok
fi
bashio::log.info "Setup HmIP-RF"

# Generate config
tempio \
    -conf /data/options.json \
    -template /usr/share/tempio/crRFD.conf \
    -out /etc/config/crRFD.conf

# Restore data
if [ -f /data/hmip_address.conf ]; then
    cp -f /data/hmip_address.conf /etc/config/
fi

# Update Firmware
#for hmip_index in $(bashio::config 'hmip|keys'); do
#    hmip_device=$(bashio::config "hmip[${hmip_index}].device")
#
#    # Skeep device path with id 
#    if echo "${hmip_device}" | grep "by-id"; then
#        bashio::log.warning "Skip firmware for ${hmip_device}"
#        continue
#    fi
#
#    version_from="$(java -Xmx64m -jar /opt/HmIP/hmip-copro-update.jar -p "${hmip_device}" -v | grep "Application version =" | cut -d' ' -f5)"
#    version_to="$(ls /firmware/HmIP-RFUSB/hmip_coprocessor_update-*.eq3 | sed 's/.*hmip_coprocessor_update-\(.*\)\.eq3/\1/' | tail -n1)"
#    if [ "${version_from}" != "${version_to}" ]; then
#        if java -Xmx64m -jar /opt/HmIP/hmip-copro-update.jar -p "${hmip_device}" -f "/firmware/HmIP-RFUSB/hmip_coprocessor_update-${version_to}.eq3"; then
#            bashio::log.info "HmIP update to ${version_to} was successful"
#        else
#            bashio::log.error "HmIP update ${version_to} fails!"
#        fi
#    fi
#done
