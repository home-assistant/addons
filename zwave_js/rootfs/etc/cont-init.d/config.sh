#!/usr/bin/with-contenv bashio
# ==============================================================================
# Generate Z-Wave JS config file
# ==============================================================================
declare network_key
declare network_key_upper
declare s0_legacy_key
declare s0_legacy
declare s2_access_control
declare s2_authenticated
declare s2_unauthenticated
declare log_level
declare flush_to_disk
declare host_chassis
declare soft_reset
declare presets_array
declare presets

readonly DOCS_EXAMPLE_KEY_1="2232666D100F795E5BB17F0A1BB7A146"
readonly DOCS_EXAMPLE_KEY_2="A97D2A51A6D4022998BEFC7B5DAE8EA1"
readonly DOCS_EXAMPLE_KEY_3="309D4AAEF63EFD85967D76ECA014D1DF"
readonly DOCS_EXAMPLE_KEY_4="CF338FE0CB99549F7C0EA96308E5A403"

if bashio::config.has_value 'network_key'; then
    # If both 'network_key' and 's0_legacy_key' are set and keys don't match,
    # we don't know which one to pick so we have to exit. If they are both set
    # and do match, we don't need to do anything
    if bashio::config.has_value 's0_legacy_key'; then
        network_key=$(bashio::string.upper "$(bashio::config 'network_key')")
        s0_legacy_key=$(bashio::string.upper "$(bashio::config 's0_legacy_key')")
        if [ "${network_key}" == "${s0_legacy_key}" ]; then
            bashio::log.info "Both 'network_key' and 's0_legacy_key' are set and match. All ok."
        else
            bashio::log.fatal "Both 'network_key' and 's0_legacy_key' are set to different values "
            bashio::log.fatal "so we are unsure which one to use. One needs to be removed from the "
            bashio::log.fatal "configuration in order to start the addon."
            bashio::exit.nok
        fi
    # If we get here, 'network_key' is set and 's0_legacy_key' is not set so we need
    # to migrate the key from 'network_key' to 's0_legacy_key'
    else
        bashio::log.info "Migrating \"network_key\" option to \"s0_legacy_key\"..."
        bashio::addon.option s0_legacy_key "$(bashio::config 'network_key')"
        bashio::log.info "Flushing config to disk due to key migration..."
        bashio::addon.options >"/data/options.json"
    fi
fi

# Validate that no keys are using the example from the docs and generate new random
# keys for any missing keys.
for key in "s0_legacy_key" "s2_access_control_key" "s2_authenticated_key" "s2_unauthenticated_key"; do
    network_key=$(bashio::config "${key}")
    network_key_upper=$(bashio::string.upper "${network_key}")
    if [ "${network_key_upper}" == "${DOCS_EXAMPLE_KEY_1}" ] || [ "${network_key_upper}" == "${DOCS_EXAMPLE_KEY_2}" ] || [ "${network_key_upper}" == "${DOCS_EXAMPLE_KEY_3}" ] || [ "${network_key_upper}" == "${DOCS_EXAMPLE_KEY_4}" ]; then
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
        network_key="$(hexdump -n 16 -e '4/4 "%08X" 1 "\n"' /dev/random)"
        bashio::addon.option ${key} "${network_key}"
        flush_to_disk=1
    fi

    # If `network_key` is unset, we set it to match `s0_legacy_key` for backwards compatibility
    if bashio::var.equals "${key}" "s0_legacy_key" && ! bashio::config.has_value "network_key"; then
        bashio::log.info "No 'network_key' detected, setting it to 's0_legacy_key' for backwards compatibility"
        bashio::addon.option network_key "${network_key}"
        flush_to_disk=1
    fi
done

# If flush_to_disk is set, it means we have generated new key(s) and they need to get
# flushed to disk
if [[ ${flush_to_disk:+x} ]]; then
    bashio::log.info "Flushing config to disk due to creation of new key(s)..."
    bashio::addon.options >"/data/options.json"
fi

s0_legacy=$(bashio::config "s0_legacy_key")
s2_access_control=$(bashio::config "s2_access_control_key")
s2_authenticated=$(bashio::config "s2_authenticated_key")
s2_unauthenticated=$(bashio::config "s2_unauthenticated_key")

if ! bashio::config.has_value 'log_level'; then
    log_level=$(bashio::info.logging)
    bashio::log.info "No log level specified, falling back to Supervisor"
    bashio::log.info "log level (${log_level})..."
else
    log_level=$(bashio::config 'log_level')
fi

host_chassis=$(bashio::host.chassis)

if bashio::config.equals 'soft_reset' 'Automatic'; then
    bashio::log.info "Soft-reset set to automatic"
    if [ "${host_chassis}" == "vm" ]; then
        soft_reset=false
        bashio::log.info "Virtual Machine detected, disabling soft-reset"
    else
        soft_reset=true
        bashio::log.info "Virtual Machine not detected, enabling soft-reset"
    fi
elif bashio::config.equals 'soft_reset' 'Enabled'; then
    soft_reset=true
    bashio::log.info "Soft-reset enabled by user"
else
    soft_reset=false
    bashio::log.info "Soft-reset disabled by user"
fi

# Create empty presets array
presets_array=()

if bashio::config.true 'safe_mode'; then
    bashio::log.info "Safe mode enabled"
    bashio::log.warning "WARNING: While in safe mode, the performance of your Z-Wave network will be in a reduced state. This is only meant for debugging purposes."
    # Add SAFE_MODE to presets array
    presets_array+=("SAFE_MODE")
fi

if bashio::config.true 'disable_controller_recovery'; then
    bashio::log.info "Automatic controller recovery disabled"
    bashio::log.warning "WARNING: If your controller becomes unresponsive, commands may start to fail and nodes may start to get marked as dead until the controller is able to recover on its own. If it doesn't recover on its own, you will need to restart the add-on manually to try to recover yourself."
    # Add NO_CONTROLLER_RECOVERY to presets array
    presets_array+=("NO_CONTROLLER_RECOVERY")
fi

# Convert presets array to JSON string and add to config
if [[ ${#presets_array[@]} -eq 0 ]]; then
    presets="[]"
else
    presets="$(printf '%s\n' "${presets_array[@]}" | jq -R . | jq -s .)"
fi

# Generate config
bashio::var.json \
    s0_legacy "${s0_legacy}" \
    s2_access_control "${s2_access_control}" \
    s2_authenticated "${s2_authenticated}" \
    s2_unauthenticated "${s2_unauthenticated}" \
    log_level "${log_level}" \
    soft_reset "^${soft_reset}" \
    presets "${presets}" |
    tempio \
        -template /usr/share/tempio/zwave_config.conf \
        -out /etc/zwave_config.json
