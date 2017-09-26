#!/bin/bash
set -e

# Map hassio value into hass-configurator options
python3 /map.py /tmp/configurator.json

# Run configurator
exec python3 /configurator.py /tmp/configurator.json
