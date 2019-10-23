#!/usr/bin/env bashio

WAIT_PIDS=()

# HA Discovery
config=$(\
    bashio::var.json \
        host "$(hostname)" \
        port "3000" \
)

if bashio::discovery "almond" "${config}" > /dev/null; then
    bashio::log.info "Successfully send discovery information to Home Assistant."
else
    bashio::log.error "Discovery message to Home Assistant failed!"
fi

# Ingress handling
export THINGENGINE_BASE_URL=$(bashio::addon.ingress_url)

# Setup nginx
nginx -c /etc/nginx/nginx.conf &
WAIT_PIDS+=($!)

yarn start &
WAIT_PIDS+=($!)

# Register stop
function stop_addon() {
    echo "Kill Processes..."
    kill -15 "${WAIT_PIDS[@]}"
    wait "${WAIT_PIDS[@]}"
    echo "Done."
}
trap "stop_addon" SIGTERM SIGHUP

# Wait until all is done
wait "${WAIT_PIDS[@]}"
