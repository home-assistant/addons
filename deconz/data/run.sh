#!/usr/bin/env bashio

DECONZ_DEVICE="$(bashio::config 'device')"
WAIT_PIDS=()

# List all devices
GCFFlasher_internal -l

# Start Gateway
bashio::log.info "Start deCONZ gateway"
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
bashio::log.info "Run deCONZ OTA updater"
deCONZ-otau-dl.sh > /dev/null &
WAIT_PIDS+=($!)

# Start OTA updates for IKEA
bashio::log.info "Run IKEA OTA updater"
ika-otau-dl.sh > /dev/null &
WAIT_PIDS+=($!)

# Start Ingress handler
bashio::log.info "Start Ingress handler"
nginx -c /etc/nginx/ingress.conf &
WAIT_PIDS+=($!)

# Register stop
function stop_addon() {
    bashio::log.debug "Kill Processes..."
    kill -15 "${WAIT_PIDS[@]}"
    wait "${WAIT_PIDS[@]}"
    bashio::log.debug "Done."
}
trap "stop_addon" SIGTERM SIGHUP

# Wait until all is done
bashio::log.info "deCONZ is setup and running"
wait "${WAIT_PIDS[@]}"
