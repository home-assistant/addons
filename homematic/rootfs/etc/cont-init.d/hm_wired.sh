#!/usr/bin/with-contenv bashio
# ==============================================================================
# Update HomeMatic firmware
# ==============================================================================
# shellcheck disable=SC2012
declare wired_index
declare wired_serial
declare wired_key
declare wired_ip

# Wired support
if bashio::config.false 'wired_enable'; then
    bashio::exit.ok
fi
bashio::log.info "Setup Hm-Wired"

for wired_index in $(bashio::config 'wired|keys'); do
    wired_serial=$(bashio::config "wired[${wired_index}].serial")
    wired_key=$(bashio::config "wired[${wired_index}].key")
    wired_ip=$(bashio::config "wired[${wired_index}].ip")

    # Update config
    (
        echo "[Interface $1]"
        echo "Type = HMWLGW"
        echo "Serial Number = ${wired_serial}"
        echo "Encryption Key = ${wired_key}"
        echo "IP Address = ${wired_ip}"
    ) >> /etc/config/hs485d.conf
done

# Update Firmware
if "${HM_HOME}/bin/eq3configcmd" update-lgw-firmware -m /firmware/fwmap -c /etc/config/hs485d.conf -l 1; then
    bashio::log.info "Wired update was successful"
else
    bashio::log.error "Wired update fails!"
fi
