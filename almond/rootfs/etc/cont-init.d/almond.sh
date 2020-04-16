#!/usr/bin/with-contenv bashio
# ==============================================================================
# Prepare the Almond service for running
# ==============================================================================
readonly PREFS_DB="${THINGENGINE_HOME}/prefs.db"

if ! bashio::fs.file_exists "${PREFS_DB}"; then
    # Ensure Thing Engine home directory exists
    mkdir -p "${THINGENGINE_HOME}"
    
    # Skip authentication handling
    echo '{"server-login":{"password":"x","salt":"x","sqliteKeySalt":"x"}}' \
      > "${PREFS_DB}"
fi
