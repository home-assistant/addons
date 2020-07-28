#!/usr/bin/with-contenv bashio
# ==============================================================================
# Configure VNC for use with deCONZ
# ==============================================================================
TMP_FOLDER=$(mktemp -d)

# Setup globals
echo "${TMP_FOLDER}" > /var/run/s6/container_environment/XDG_RUNTIME_DIR
echo ":0" > /var/run/s6/container_environment/DISPLAY

# VNC is not enabled as a seperate service, as it cannot handle multiple
# session when running in the foreground.
VNC_PORT="$(bashio::addon.port 5900)"
ARCH="$(bashio::info.arch)"

# Fix tigervnc for 32 bits ARM
if [[ "armhf armv7" = *"${ARCH}"* ]]; then
    export LD_PRELOAD=/lib/arm-linux-gnueabihf/libgcc_s.so.1
fi

# Fix tigervnc for 64 bits ARM
if [[ "aarch64" = "${ARCH}" ]]; then
    export LD_PRELOAD=/lib/aarch64-linux-gnu/libgcc_s.so.1
fi

# Run it only on localhost if not expose
if bashio::var.has_value "${VNC_PORT}"; then
    LOCAL_ONLY=no
else
    LOCAL_ONLY=yes
fi

export XDG_RUNTIME_DIR="${TMP_FOLDER}"
export DISPLAY=":0"

bashio::log.info "Starting VNC server (local/${LOCAL_ONLY})..."
tigervncserver \
    -name "Home Assistant - deCONZ" \
    -geometry 1920x1080 \
    -depth 16 \
    -localhost ${LOCAL_ONLY} \
    -SecurityTypes None \
    "${DISPLAY}"
    &> /dev/null
