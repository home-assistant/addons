#!/usr/bin/with-contenv bash
# vim: ft=bash
# shellcheck shell=bash

# Populate the provided array variable with enabled network interfaces.
get_enabled_interfaces() {
    local -n _out_interfaces=$1
    local interface
    local interface_enabled

    _out_interfaces=()
    for interface in $(bashio::network.interfaces); do
        interface_enabled=$(bashio::network.enabled "${interface}")
        if bashio::var.true "${interface_enabled}"; then
            _out_interfaces+=("${interface}")
        fi
    done
}
