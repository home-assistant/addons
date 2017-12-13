#!/bin/bash
set -e

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

$HM_HOME/bin/rfd -d -l 0 -f /opt/hm/etc/config/rfd.conf 
$HM_HOME/bin/ReGaHss -l 0 -f /opt/hm/etc/rega.conf
