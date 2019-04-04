#!/usr/bin/env bashio
set -e

WAIT_PIDS=()

# Setup and run Frontend
sed -i "s/%%PORT%%/8080/g" /etc/nginx/nginx.conf
nginx -c /etc/nginx/nginx.conf &
WAIT_PIDS+=($!)

# Setup and run configurator
sed -i "s/%%TOKEN%%/${HASSIO_TOKEN}/g" /etc/configurator.conf
hass-configurator /etc/configurator.conf &
WAIT_PIDS+=($!)

# Register stop
function stop_addon() {
    bashio::log.info "Kill Processes..."
    kill -15 "${WAIT_PIDS[@]}"
    wait "${WAIT_PIDS[@]}"
    bashio::log.info "Done."
}
trap "stop_addon" SIGTERM SIGHUP

# Wait until all is done
bashio::log.info "Add-on running"
wait "${WAIT_PIDS[@]}"
