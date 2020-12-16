#!/usr/bin/with-contenv bashio
# ==============================================================================
# Generate InterfacesList.xml
# ==============================================================================
tempio \
    -conf /data/options.json \
    -template /usr/share/tempio/InterfacesList.xml \
    -out /etc/config/InterfacesList.xml
