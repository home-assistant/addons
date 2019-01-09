#!/bin/bash
set -e

CONFIG_PATH=/data/options.json

DECONZ_WEB_PORT="$(jq --raw-output '.web_port' $CONFIG_PATH)"
DECONZ_WS_PORT="$(jq --raw-output '.websockets_port' $CONFIG_PATH)"
DECONZ_DEVICE="$(jq --raw-output '.deconz_device' $CONFIG_PATH)"

/usr/bin/deCONZ \
    -platform minimal \
    --auto-connect=1 \
    --dbg-info=1 \
    --dbg-aps=0 \
    --dbg-zcl=0 \
    --dbg-zdp=0 \
    --dbg-otau=0 \
    --http-port=$DECONZ_WEB_PORT \
    --ws-port=$DECONZ_WS_PORT \
    --dev=$DECONZ_DEVICE
    