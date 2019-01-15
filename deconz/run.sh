#!/bin/bash
set -e

CONFIG_PATH=/data/options.json
DECONZ_DEVICE="$(jq --raw-output '.device' $CONFIG_PATH)"
WAIT_PIDS=()

# List all devices
GCFFlasher_internal -l

# Start Gateway
deCONZ \
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
    --dev="${DECONZ_DEVICE}" &
WAIT_PIDS+=($!)

# Start OTA updates for deCONZ
deCONZ-otau-dl.sh &
WAIT_PIDS+=($!)

# Start OTA updates for IKEA
ika-otau-dl.sh &
WAIT_PIDS+=($!)

# Register stop
function stop_addon() {
    echo "Kill Processes..."
    kill -15 "${WAIT_PIDS[@]}"
    wait "${WAIT_PIDS[@]}"
    echo "Done."
}
trap "stop_addon" SIGTERM SIGHUP

# Wait until all is done
wait "${WAIT_PIDS[@]}"
