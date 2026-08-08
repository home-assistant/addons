#!/usr/bin/with-contenv bashio
# vim: ft=bash
# shellcheck shell=bash
# ==============================================================================
# otbr-wpan-sysctl
# Waits for the Thread interface to appear, then applies IPv6 hardening
# with retries. Designed for the real behaviour of wpan0 in OTBR containers.
# ==============================================================================

THREAD_IF="${thread_if:-wpan0}"

bashio::log.info "otbr-wpan-sysctl: waiting for ${THREAD_IF} directory to appear..."

MAX_WAIT=60
elapsed=0

# Only wait for the sysctl directory – this is the reliable signal
while [ ! -d "/proc/sys/net/ipv6/conf/${THREAD_IF}" ]; do
    if [ "${elapsed}" -ge "${MAX_WAIT}" ]; then
        bashio::log.error "otbr-wpan-sysctl: timed out after ${MAX_WAIT}s waiting for ${THREAD_IF}"
        exit 1
    fi
    sleep 1
    elapsed=$((elapsed + 1))
done

bashio::log.info "otbr-wpan-sysctl: ${THREAD_IF} present – current values:"

for key in accept_ra accept_ra_defrtr accept_ra_pinfo forwarding; do
    val=$(sysctl -n "net.ipv6.conf.${THREAD_IF}.${key}" 2>/dev/null || echo "unreadable")
    bashio::log.info "  ${key} = ${val}"
done

sysctl -w "net.ipv6.conf.${THREAD_IF}.accept_ra=0"        >/dev/null 2>&1 || true
sysctl -w "net.ipv6.conf.${THREAD_IF}.accept_ra_defrtr=0" >/dev/null 2>&1 || true
sysctl -w "net.ipv6.conf.${THREAD_IF}.accept_ra_pinfo=0"  >/dev/null 2>&1 || true
sysctl -w "net.ipv6.conf.${THREAD_IF}.forwarding=1"       >/dev/null 2>&1 || true

exit 0   # always succeed