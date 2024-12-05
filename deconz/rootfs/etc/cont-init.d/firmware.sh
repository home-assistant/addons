#!/usr/bin/with-contenv bashio
# shellcheck shell=bash
# ==============================================================================
# Manage deCONZ firmware
# ==============================================================================

bashio::log.info "$(/usr/bin/GCFFlasher_internal -l)"
