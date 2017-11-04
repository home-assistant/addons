#!/bin/bash

set -e

echo Starting run.sh...

if [ ! -f /config/tellstick.conf ]; then
    cp /usr/src/tellstick.conf /config
fi

telldusd --version 

exec /usr/local/sbin/telldusd < /dev/null
