#!/usr/bin/env bashio
set -e

bashio::log.info "Starting CEC client scan..."
echo scan | cec-client -s -d 1
