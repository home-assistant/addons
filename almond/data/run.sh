#!/usr/bin/env bashio

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

exec yarn start < /dev/null
