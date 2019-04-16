#!/usr/bin/env bashio
set -e

. /discovery.sh

WAIT_PIDS=()

# Load config
DECONZ_DEVICE=$(bashio::config 'device')
API_PORT=$(bashio::addon.port 80)
WEBSOCKET_PORT=$(bashio::addon.port 8080)
INGRESS_PORT=$(bashio::addon.ingress_port)
INGRESS_INTERFACE=$(bashio::addon.ip_address)

# Check if port is available
if [ -z "${API_PORT}" ] || [ -z "${WEBSOCKET_PORT}" ]; then
    bashio::exit.nok "You need set API/Websocket port!"
fi

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
    --http-port=${API_PORT} \
    --ws-port=${WEBSOCKET_PORT} \
    --upnp=0 \
    --dev="${DECONZ_DEVICE}" &
WAIT_PIDS+=($!)

# Start OTA updates for deCONZ
bashio::log.info "Run deCONZ OTA updater"
deCONZ-otau-dl.sh &> /dev/null &
WAIT_PIDS+=($!)

# Start OTA updates for IKEA
bashio::log.info "Run IKEA OTA updater"
ika-otau-dl.sh &> /dev/null &
WAIT_PIDS+=($!)

# Register stop
function stop_addon() {
    bashio::log.debug "Kill Processes..."
    kill -15 "${WAIT_PIDS[@]}"

    wait "${WAIT_PIDS[@]}"
    bashio::log.debug "Done."
}
trap "stop_addon" SIGTERM SIGHUP

# Start Hass.io discovery
bashio::log.info "Run Hass.io discovery task"
hassio_discovery

# Wait until all is done
bashio::log.info "deCONZ is setup and running"
wait "${WAIT_PIDS[@]}"
