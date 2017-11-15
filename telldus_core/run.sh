#!/bin/bash

set -e

echo "[Info] Initialize the tellstick configuration"

# TODO: init config

# Expose the unix socket to internal network
socat TCP-LISTEN:50800,reuseaddr,fork UNIX-CONNECT:/tmp/TelldusClient &

exec /usr/local/sbin/telldusd --nodaemon < /dev/null
