#!/usr/bin/with-contenv bashio
# ==============================================================================
# Generate Z-Wave JS config file
# ==============================================================================
declare network_key
declare flush_to_disk

flush_to_disk=false

readonly DOCS_EXAMPLE_KEY="2232666D100F795E5BB17F0A1BB7A146"

if bashio::config.has_value 'network_key'; then
    bashio::log.info "Migrating \"network_key\" option to \"s0_legacy_key\"..."
    network_key=$(bashio::string.upper "$(bashio::config 'network_key')")
    bashio::addon.option s0_legacy_key "${network_key}"
    bashio::addon.option network_key
    flush_to_disk=true
fi

# We need to restart if we migrated the key so it gets flushed to disk
if [[ ${flush_to_disk} ]]; then
    bashio::log.info "Flushing config to disk due to migration"
    bashio::addon.options > "/data/options.json"
    flush_to_disk=false
fi

for key in "s0_legacy_key" "s2_access_control_key" "s2_authenticated_key" "s2_unauthenticated_key"; do
    network_key=$(bashio::config "${key}")
    if [[ "${DOCS_EXAMPLE_KEY}" == "${network_key}" ]]; then
        bashio::log.fatal
        bashio::log.fatal "The add-on detected that the Z-Wave network key used"
        bashio::log.fatal "is from the documented example."
        bashio::log.fatal
        bashio::log.fatal "Using this key is insecure, because it is publicly"
        bashio::log.fatal "listed in the documentation."
        bashio::log.fatal
        bashio::log.fatal "Please check the add-on documentation on how to"
        bashio::log.fatal "create your own, secret, \"${key}\" and replace"
        bashio::log.fatal "the one you have configured."
        bashio::log.fatal
        bashio::log.fatal "Click on the \"Documentation\" tab in the Z-Wave JS"
        bashio::log.fatal "add-on panel for more information."
        bashio::log.fatal
        bashio::exit.nok
    elif ! bashio::var.has_value "${network_key}"; then
        bashio::log.info "No ${key} is set, generating one..."
        bashio::addon.option ${key} "$(hexdump -n 16 -e '4/4 "%08X" 1 "\n"' /dev/random)"
        flush_to_disk=true
    fi
done

# We need to restart if we created new key(s) so they get flushed to disk
if [[ ${flush_to_disk} ]]; then
    bashio::log.info "Flushing config to disk due to creation of new keys"
    bashio::addon.options > "/data/options.json"
    flush_to_disk=false
fi

s0_legacy=$(bashio::config "s0_legacy_key")
s2_access_control=$(bashio::config "s2_access_control_key")
s2_authenticated=$(bashio::config "s2_authenticated_key")
s2_unauthenticated=$(bashio::config "s2_unauthenticated_key")

if  ! bashio::config.has_value 'log_level'; then
    log_level=$(bashio::info.logging)
    bashio::log.info "No log level specified, falling back to Supervisor"
    bashio::log.info "log level (${log_level})..."
else
    log_level=$(bashio::config 'log_level')
fi


# Generate config
bashio::var.json \
    s0_legacy "${s0_legacy}" \
    s2_access_control "${s2_access_control}" \
    s2_authenticated "${s2_authenticated}" \
    s2_unauthenticated "${s2_unauthenticated}" \
    log_level "${log_level}" \
    | tempio \
        -template /usr/share/tempio/zwave_config.conf \
        -out /etc/zwave_config.json
