#!/bin/bash

set -e

echo Starting run.sh...

if [ ! -f /config/tellstick.conf ]; then
    cp /usr/src/tellstick.conf /config
fi

telldusd --version 
#running telldusd with option --nodaemon otherwise the docker stops unexpectedly..
exec /usr/local/sbin/telldusd --nodaemon
