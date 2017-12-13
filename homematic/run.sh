#!/bin/bash
set -e
export HM_HOME=/opt/hm
export LD_LIBRARY_PATH=$HM_HOME/lib

CONFIG_PATH=/data/options.json

TYPE=$(jq --raw-output ".type" $CONFIG_PATH)
DEVICE=$(jq --raw-output ".device" $CONFIG_PATH)

# Update config
if [ "$TYPE" == "CCU2" ]; then
    (
        echo "Type = CCU2"
        echo "ComPortFile = $DEVICE"
        echo "AccessFile = /dev/null"
        echo "ResetFile = /sys/class/gpio/gpio18/value"
    ) >> /etc/config/rfd.conf
fi

# Init folder
mkdir -p /data/firmware

# Init GPIO
if [ ! -d /sys/class/gpio/gpio18 ]; then
    echo 18 > /sys/class/gpio/export
    sleep 2
fi
if [ "$(cat /sys/class/gpio/gpio18/direction)" != "out" ]; then
    echo out > /sys/class/gpio/gpio18/direction
    sleep 2
fi

# Run central
#"$HM_HOME/bin/rfd" -d -l 0 -f /opt/hm/etc/config/rfd.conf
"$HM_HOME/bin/rfd" -c -l 0 -f /opt/hm/etc/config/rfd.conf
"$HM_HOME/bin/ReGaHss" -l 0 -f /opt/hm/etc/rega.conf
