#!/usr/bin/with-contenv bashio
# ==============================================================================
# Configure VNC for use with deCONZ
# ==============================================================================

# Setup globals
echo "$(mktemp -d)" > /var/run/s6/container_environment/XDG_RUNTIME_DIR
echo ":0" > /var/run/s6/container_environment/DISPLAY
