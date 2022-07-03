#!/usr/bin/with-contenv bashio
# ==============================================================================
# Manage deCONZ firmware
# ==============================================================================

bashio::log.info "$(/usr/bin/GCFFlasher_internal -l)"
