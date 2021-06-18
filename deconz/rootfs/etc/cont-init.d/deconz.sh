#!/usr/bin/with-contenv bashio
# ==============================================================================
# Manage deCONZ firmware/folder
# ==============================================================================

bashio::log.info "$(/usr/bin/GCFFlasher_internal -l)"

mkdir -p /root/.local/share
mkdir -p /data/dresden-elektronik
ln -s /data/dresden-elektronik /root/.local/share/dresden-elektronik
