#!/bin/bash

echo "Your API key is: $HASSIO_TOKEN"

exec socat TCP-LISTEN:80,fork,reuseaddr TCP:hassio:80 < /dev/null
