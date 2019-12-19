#!/usr/bin/env bashio
set -e

# Init own udev service
/lib/systemd/systemd-udevd --daemon
bashio::hardware.trigger

# Ensure otau folder exists
mkdir -p "/data/otau"

# shellcheck disable=SC1091
. /discovery.sh

WAIT_PIDS=()

# Default QT platform
PLATFORM="minimal"

# Lookup udev link
bashio::log.info "Waiting for device..."
DECONZ_DEVICE=$(bashio::config 'device')
if [[ -c "${DECONZ_DEVICE}" ]]; then
    bashio::log.debug "Specified device points to a character special file, continuing"
else
    # 60 second timeout to wait for udev to finish processing
    timeout=60
    while [[ ! -L "${DECONZ_DEVICE}" ]]; do
        if [[ "${timeout}" -eq 0 ]]; then
            bashio::exit.nok "No device ${DECONZ_DEVICE} found!"
        fi
        bashio::log.debug "Waiting for udev to link device..,"
        sleep 1
        ((timeout--))
    done
    DECONZ_DEVICE="$(readlink -f "${DECONZ_DEVICE}")"
    bashio::log.debug "Found device! Location: ${DECONZ_DEVICE}"
fi

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

# Check if VNC is enabled
VNC_PORT="$(bashio::addon.port 5900)"
if bashio::var.has_value "${VNC_PORT}"; then

    TMP_FOLDER=$(mktemp -d)
    export XDG_RUNTIME_DIR="${TMP_FOLDER}"
    export DISPLAY=":0"
    PLATFORM="xcb"

    # Require password when VNC is enabled
    if ! bashio::config.has_value 'vnc_password'; then
        bashio::exit.nok "VNC has been enabled, but no password has been set!"
    fi

    bashio::log.info "Starting VNC server..."
    VNC_PASSWORD=$(bashio::config 'vnc_password')
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
    --upnp=0 \
    --http-port=8080 \
    --ws-port=8081 \
    --dev="${DECONZ_DEVICE}" &
WAIT_PIDS+=($!)

# Wait for deCONZ to start before continuing
bashio::net.wait_for 8080

# Start Nginx proxy
bashio::log.info "Starting Nginx..."
nginx &
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
hassio_discovery &

# Start OTA updates for deCONZ
bashio::log.info "Running the deCONZ OTA updater..."
deCONZ-otau-dl.sh &> /dev/null &

# Start OTA updates for IKEA
bashio::log.info "Running the IKEA OTA updater..."
ika-otau-dl.sh &> /dev/null &

# Wait until all is done
bashio::log.info "deCONZ is set up and running!"
wait "${WAIT_PIDS[@]}"
