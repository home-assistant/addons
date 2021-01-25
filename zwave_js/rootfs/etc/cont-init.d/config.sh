#!/usr/bin/with-contenv bashio
# ==============================================================================
# Generate Z-Wave JS config file
# ==============================================================================

# Generate config
tempio \
    -conf /data/options.json \
    -template /usr/share/tempio/zwave_config.json \
    -out /etc/zwave_config.json
