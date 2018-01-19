#!/bin/bash
set -e

CONFIG_PATH=/data/options.json

RF_ENABLE=$(jq --raw-output '.rf_enable' $CONFIG_PATH)
RF_DEVICES=$(jq --raw-output '.rf | length' $CONFIG_PATH)
WIRED_ENABLE=$(jq --raw-output '.wired_enable' $CONFIG_PATH)
WIRED_DEVICES=$(jq --raw-output '.wired | length' $CONFIG_PATH)
WAIT_PIDS=()

# Init folder
mkdir -p /data/firmware

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
                echo 1 > /sys/class/gpio/gpio18/direction
                sleep 0.5    
            fi
            echo 0 > /sys/class/gpio/gpio18/direction
            sleep 0.5
        fi
    done

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

    # Run hs485d
    "$HM_HOME/bin/hs485d" -g -i 0 -f /opt/hm/etc/config/hs485d.conf &
    WAIT_PIDS+=($!)
fi

# Wait until all is done
wait "${WAIT_PIDS[@]}"
