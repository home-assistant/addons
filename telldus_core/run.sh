#!/bin/bash

set -e

echo Starting run.sh...

if [ ! -f /config/tellstick.conf ]; then
    cp /usr/src/tellstick.conf /config
	sed -i -e 's/nobody/root/g' /config/tellstick.conf #required until git source is updated otherwise telldus daemon will not communicate with hardware
fi

telldusd --version 
#running telldusd with option --nodaemon otherwise the docker stops unexpectedly..
exec /usr/local/sbin/telldusd --nodaemon < /dev/null