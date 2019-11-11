#!/bin/bash
# shellcheck disable=SC2012


function firmware_update_hmip() {
    local DEVICE="$1"
    local FROM_VERSION=
    local TO_VERSION=

    FROM_VERSION="$(java -Xmx64m -jar /opt/HmIP/hmip-copro-update.jar -p "${DEVICE}" -v | grep "Application version =" | cut -d' ' -f5)"
    TO_VERSION="$(ls /firmware/HmIP-RFUSB/hmip_coprocessor_update-*.eq3 | sed 's/.*hmip_coprocessor_update-\(.*\)\.eq3/\1/' | tail -n1)"
    if [ "${FROM_VERSION}" != "${TO_VERSION}" ]; then
        if java -Xmx64m -jar /opt/HmIP/hmip-copro-update.jar -p "${DEVICE}" -f "/firmware/HmIP-RFUSB/hmip_coprocessor_update-${TO_VERSION}.eq3"; then
            echo "[INFO] HmIP update to ${TO_VERSION} was successful"
        else
            echo "[ERROR] HmIP update ${TO_VERSION} fails!"
        fi
    fi
}


function firmware_update_rfd() {
    if "${HM_HOME}/bin/eq3configcmd" update-coprocessor -lgw -u -rfdconf /etc/config/rfd.conf -l 1; then
        echo "[INFO] RFd update was successful"
    else
        echo "[ERROR] RFd update fails!"
    fi
}


function firmware_update_wired() {
	if "${HM_HOME}/bin/eq3configcmd" update-lgw-firmware -m /firmware/fwmap -c /etc/config/hs485d.conf -l 1; then
        echo "[INFO] Wired update was successful"
    else
        echo "[ERROR] Wired update fails!"
    fi
}
