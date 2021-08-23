#!/usr/bin/with-contenv bashio
# ==============================================================================
# Generate Z-Wave JS config file
# ==============================================================================
declare network_key

readonly DOCS_EXAMPLE_KEY="2232666D100F795E5BB17F0A1BB7A146"

if bashio::config.has_value 'network_key'; then
    bashio::log.info "Migrating \"network_key\" option to \"s0_legacy_key\"..."
    network_key=$(bashio::config 'network_key')
    bashio::addon.option s0_legacy_key "$(bashio::string.upper ${network_key})"
    bashio::addon.option network_key
fi

for key in "s0_legacy_key" "s2_accesscontrol_key" "s2_authenticated_key" "s2_unauthenticated_key"; do
    network_key=$(bashio::jq "$(bashio::addon.options)" .${key})
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
    fi
done
options="$(bashio::addon.options)"
s0_legacy=$(bashio::jq "${options}" .s0_legacy_key)
s2_accesscontrol=$(bashio::jq "${options}" .s2_accesscontrol_key)
s2_authenticated=$(bashio::jq "${options}" .s2_authenticated_key)
s2_unauthenticated=$(bashio::jq "${options}" .s2_unauthenticated_key)

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
    s2_accesscontrol "${s2_accesscontrol}" \
    s2_authenticated "${s2_authenticated}" \
    s2_unauthenticated "${s2_unauthenticated}" \
    log_level "${log_level}" \
    | tempio \
        -template /usr/share/tempio/zwave_config.conf \
        -out /etc/zwave_config.json
