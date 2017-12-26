#!/bin/sh
set -e

CONFIG_PATH=/data/options.json

SERIAL_DEVICE=$(jq --raw-output ".serialDevice" $CONFIG_PATH)
BAUD_RATE=$(jq --raw-output ".baudRate" $CONFIG_PATH)
LISTEN_PORT=$(jq --raw-output ".port" $CONFIG_PATH)

ser2sock -g 2 -f /etc/ser2sock.conf -p ${LISTEN_PORT} -s ${SERIAL_DEVICE} -b ${BAUD_RATE}
