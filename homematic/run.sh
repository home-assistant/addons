#!/bin/bash
set -e

CONFIG_PATH=/data/options.json

RF_ENABLE=$(jq --raw-output '.rf_enable' $CONFIG_PATH)
RF_DEVICES=$(jq --raw-output '.rf | length' $CONFIG_PATH)
WIRED_ENABLE=$(jq --raw-output '.wired_enable' $CONFIG_PATH)
WIRED_DEVICES=$(jq --raw-output '.wired | length' $CONFIG_PATH)
HMIP_ENABLE=$(jq --raw-output '.hmip_enable' $CONFIG_PATH)
HMIP_DEVICES=$(jq --raw-output '.hmip | length' $CONFIG_PATH)
WAIT_PIDS=()

# Init folder
mkdir -p /share/firmware
mkdir -p /data/crRFD
mkdir -p /data/rfd

. /usr/lib/hm-firmware.sh

# RF support
if [ "$RF_ENABLE" == "true" ]; then
    for (( i=0; i < "$RF_DEVICES"; i++ )); do
        TYPE=$(jq --raw-output ".rf[$i].type" $CONFIG_PATH)

        # Update config
        if [ "$TYPE" == "CCU2" ]; then
            DEVICE=$(jq --raw-output ".rf[$i].device" $CONFIG_PATH)
            (
                echo "[Interface $1]"
                echo "Type = CCU2"
                echo "ComPortFile = $DEVICE"
                echo "AccessFile = /dev/null"
                echo "ResetFile = /sys/class/gpio/gpio18/value"
            ) >> /etc/config/rfd.conf


            # Init GPIO
            RESET=$(jq --raw-output ".rf[$i].reset // false" $CONFIG_PATH)
            if [ ! -d /sys/class/gpio/gpio18 ]; then
                echo 18 > /sys/class/gpio/export
                sleep 2
            fi
            if [ "$(cat /sys/class/gpio/gpio18/direction)" != "out" ]; then
                echo out > /sys/class/gpio/gpio18/direction
                sleep 2
            fi
            if [ "$RESET" == "true" ]; then
                echo 1 > /sys/class/gpio/gpio18/value || echo "Can't reset module!"
                sleep 0.5
            fi
            echo 0 > /sys/class/gpio/gpio18/value || echo "Can't set default value!"
            sleep 0.5
        fi
    done

    # Update Firmware
    firmware_update_rfd

    # Run RFD
    "$HM_HOME/bin/rfd" -c -l 0 -f /opt/hm/etc/config/rfd.conf &
    WAIT_PIDS+=($!)
fi

# Wired support
if [ "$WIRED_ENABLE" == "true" ]; then
    for (( i=0; i < "$WIRED_DEVICES"; i++ )); do
        SERIAL=$(jq --raw-output ".wired[$i].serial" $CONFIG_PATH)
        KEY=$(jq --raw-output ".wired[$i].key" $CONFIG_PATH)
        IP=$(jq --raw-output ".wired[$i].ip" $CONFIG_PATH)

        # Update config
        (
            echo "[Interface $1]"
            echo "Type = HMWLGW"
            echo "Serial Number = $SERIAL"
            echo "Encryption Key = $KEY"
            echo "IP Address = $IP"
        ) >> /etc/config/hs485d.conf
    done

    # Update Firmware
    firmware_update_wired

    # Run hs485d
    "$HM_HOME/bin/hs485d" -g -i 0 -f /opt/hm/etc/config/hs485d.conf &
    WAIT_PIDS+=($!)
fi

# HMIP support
if [ "$HMIP_ENABLE" == "true" ]; then
    # Restore data
    if [ -f /data/hmip_address.conf ]; then
        cp -f /data/hmip_address.conf /etc/config/
    fi

    # Setup settings
    for (( i=0; i < "$HMIP_DEVICES"; i++ )); do
        TYPE=$(jq --raw-output ".hmip[$i].type" $CONFIG_PATH)
        DEVICE=$(jq --raw-output ".hmip[$i].device" $CONFIG_PATH)
        ADAPTER=$((i+1))

        # Update Firmware
        firmware_update_hmip "${DEVICE}"

        # Update config
        (
            echo "Adapter.${ADAPTER}.Type=${TYPE}"
            echo "Adapter.${ADAPTER}.Port=${DEVICE}"
        ) >> /etc/config/crRFD.conf
    done

    # Run HMIPServer
    # shellcheck disable=SC2086
    java -Xmx64m -Dlog4j.configuration=file:///etc/config/log4j.xml -Dfile.encoding=ISO-8859-1 -jar /opt/HMServer/HMIPServer.jar /etc/config/crRFD.conf &
    WAIT_PIDS+=($!)

    if [ ! -f /data/hmip_address.conf ]; then
        sleep 30
        cp -f /etc/config/hmip_address.conf /data/
    fi
fi

# Register stop
function stop_homematic() {
    echo "Kill Processes..."
    kill -15 "${WAIT_PIDS[@]}"
    wait "${WAIT_PIDS[@]}"
    echo "Done."
}
trap "stop_homematic" SIGTERM SIGHUP

# sync time periodically
if [ "$RF_ENABLE" == "true" ]; then
    while true
    do
        sleep 30m
        echo "$(date '+%Y-%m-%d %H:%M:%S.%3N') Run SetInterfaceClock now."
        "$HM_HOME/bin/SetInterfaceClock" 127.0.0.1:2001
    done
fi

# Wait until all is done
wait "${WAIT_PIDS[@]}"
