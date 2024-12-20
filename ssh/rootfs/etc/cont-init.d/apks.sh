#!/usr/bin/with-contenv bashio
# shellcheck shell=bash
# ==============================================================================
# SSH install additional packages on startup
# ==============================================================================

if ! bashio::config.has_value "apks"; then
    bashio::exit.ok
fi

apk update \
    || bashio::exit.nok "Failed updating Alpine packages indexes"

for package in $(bashio::config "apks"); do
    apk add "$package" \
        || bashio::exit.nok "Failed installing ${package}"
done
