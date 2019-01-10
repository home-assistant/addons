#!/bin/bash
set -e

CONFIG_PATH=/data/options.json
DECONZ_DEVICE="$(jq --raw-output '.deconz_device' $CONFIG_PATH)"

exec deCONZ \
    -platform minimal \
    --auto-connect=1 \
    --dbg-info=1 \
    --dbg-aps=0 \
    --dbg-zcl=0 \
    --dbg-zdp=0 \
    --dbg-otau=0 \
    --http-port=80 \
    --ws-port=8080 \
    --upnp=0 \
    --dev="${DECONZ_DEVICE}"
    
