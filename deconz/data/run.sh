#!/usr/bin/env bashio
set -e

# Ensure otau folder exists
mkdir -p "/data/otau"

# shellcheck disable=SC1091
. /discovery.sh

WAIT_PIDS=()

# Default QT platform
PLATFORM="minimal"

# Load config
DECONZ_DEVICE=$(bashio::config 'device')
API_PORT=$(bashio::addon.port 80)
VNC_PORT=$(bashio::addon.port 5900)
VNC_PASSWORD=$(bashio::config 'vnc_password')
WEBSOCKET_PORT=$(bashio::addon.port 8080)

# Load debug values
bashio::config.has_value 'dbg_info' \
    && DBG_INFO="$(bashio::config 'dbg_info')" || DBG_INFO=1
bashio::config.has_value 'dbg_aps' \
    && DBG_APS="$(bashio::config 'dbg_aps')" || DBG_APS=0
bashio::config.has_value 'dbg_otau' \
    && DBG_OTAU="$(bashio::config 'dbg_otau')" || DBG_OTAU=0
bashio::config.has_value 'dbg_zcl' \
    && DBG_ZCL="$(bashio::config 'dbg_zcl')" || DBG_ZCL=0
bashio::config.has_value 'dbg_zdp' \
    && DBG_ZDP="$(bashio::config 'dbg_zdp')" || DBG_ZDP=0

# Check if port is available
if bashio::var.is_empty "${API_PORT}" \
    || bashio::var.is_empty "${WEBSOCKET_PORT}";
then
    bashio::exit.nok "You need set API and Websocket port!"
fi

# Check if VNC is enabled
if bashio::var.has_value "${VNC_PORT}"; then
    if [[ "${VNC_PORT}" -lt 5900 ]]; then
        bashio::exit.nok "VNC requires the port number to be set to 5900 or higher!"
    fi

    # Check if configured VNC port is free
    if nc -z 127.0.0.1 "${VNC_PORT}"; then
        bashio::log.fatal "VNC port ${VNC_PORT} is already in use!"
        bashio::exit.nok "Please change the port number"
    fi

    TMP_FOLDER=$(mktemp -d)
    export XDG_RUNTIME_DIR="${TMP_FOLDER}"
    export DISPLAY=":$((VNC_PORT-5900))"
    PLATFORM="xcb"

    # Require password when VNC is enabled
    if ! bashio::config.has_value 'vnc_password'; then
        bashio::exit.nok "VNC has been enabled, but no password has been set!"
    fi

    bashio::log.info "Starting VNC server..."
    echo "${VNC_PASSWORD}" | tigervncpasswd -f > /root/.vncpasswd
    tigervncserver \
        -name "Hass.io - deCONZ" \
        -geometry 1920x1080 \
        -depth 16 \
        -localhost no \
        -PasswordFile /root/.vncpasswd \
        "${DISPLAY}" \
        &> /dev/null
fi

# Start deCONZ
bashio::log.info "Starting the deCONZ gateway..."
deCONZ \
    -platform "${PLATFORM}" \
    --auto-connect=1 \
    --dbg-info="${DBG_INFO}" \
    --dbg-aps="${DBG_APS}" \
    --dbg-otau="${DBG_OTAU}" \
    --dbg-zcl="${DBG_ZCL}" \
    --dbg-zdp="${DBG_ZDP}" \
    --http-port="${API_PORT}" \
    --ws-port="${WEBSOCKET_PORT}" \
    --upnp=0 \
    --dev="${DECONZ_DEVICE}" &
WAIT_PIDS+=($!)

# Start OTA updates for deCONZ
bashio::log.info "Running the deCONZ OTA updater..."
deCONZ-otau-dl.sh &> /dev/null &
WAIT_PIDS+=($!)

# Start OTA updates for IKEA
bashio::log.info "Running the IKEA OTA updater..."
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
bashio::log.info "Running Hass.io discovery task..."
hassio_discovery

# Wait until all is done
bashio::log.info "deCONZ is set up and running!"
wait "${WAIT_PIDS[@]}"
