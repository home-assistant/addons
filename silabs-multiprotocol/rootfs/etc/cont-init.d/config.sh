#!/usr/bin/with-contenv bashio
# ==============================================================================
# Generate Silicon Labs Multiprotocol configurations
# ==============================================================================

declare device
declare baudrate
declare flow_control
declare cpcd_trace

if ! bashio::config.has_value 'device'; then
    bashio::log.fatal "No serial port device set!"
    bashio::exit.nok
fi
device=$(bashio::config 'device')

if bashio::config.has_value 'network_device'; then
    device="/tmp/ttyCPC"
fi

if ! bashio::config.has_value 'baudrate'; then
    bashio::log.fatal "No serial port baudrate set!"
    bashio::exit.nok
fi
baudrate=$(bashio::config 'baudrate')

if  ! bashio::config.has_value 'flow_control'; then
    flow_control="false"
else
    flow_control=$(bashio::config 'flow_control')
fi

if  ! bashio::config.has_value 'cpcd_trace'; then
    cpcd_trace="false"
else
    cpcd_trace=$(bashio::config 'cpcd_trace')
fi

bashio::log.info "Generating cpcd configuration."
bashio::var.json \
    device "${device}" \
    baudrate "${baudrate}" \
    flow_control "${flow_control}" \
    cpcd_trace "${cpcd_trace}" \
    | tempio \
        -template /usr/local/share/cpcd.conf \
        -out /usr/local/etc/cpcd.conf
