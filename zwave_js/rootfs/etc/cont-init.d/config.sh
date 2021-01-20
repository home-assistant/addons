#!/usr/bin/with-contenv bashio
# ==============================================================================
# Generate Zwave JS config file
# ==============================================================================

# Generate config
tempio \
    -conf /data/options.json \
    -template /usr/share/tempio/zwave_config.conf \
    -out /etc/zwave_config.conf
