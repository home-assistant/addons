#!/usr/bin/with-contenv bashio
# shellcheck shell=bash
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
declare rf_region
declare rf_region_integer
declare rf_json
declare soft_reset
declare presets_array
declare presets

readonly DOCS_EXAMPLE_KEY_1="2232666D100F795E5BB17F0A1BB7A146"
readonly DOCS_EXAMPLE_KEY_2="A97D2A51A6D4022998BEFC7B5DAE8EA1"
readonly DOCS_EXAMPLE_KEY_3="309D4AAEF63EFD85967D76ECA014D1DF"
readonly DOCS_EXAMPLE_KEY_4="CF338FE0CB99549F7C0EA96308E5A403"
readonly DOCS_EXAMPLE_KEY_5="E2CEA6B5986C818EEC0D0065D81E2BD5"
readonly DOCS_EXAMPLE_KEY_6="863027C59CFC522A9A3C41976AE54254"

declare -A country_rf_region_map=(
    ["AD"]="Europe"
    ["AE"]="Europe"
    ["AF"]="Default (EU)"
    ["AG"]="Default (EU)"
    ["AI"]="Europe"
    ["AL"]="Europe"
    ["AM"]="Europe"
    ["AO"]="Default (EU)"
    ["AQ"]="Default (EU)"
    ["AR"]="USA"
    ["AS"]="USA"
    ["AT"]="Europe"
    ["AU"]="Australia/New Zealand"
    ["AW"]="Europe"
    ["AX"]="Europe"
    ["AZ"]="Europe"
    ["BA"]="Europe"
    ["BB"]="USA"
    ["BD"]="Default (EU)"
    ["BE"]="Europe"
    ["BF"]="Default (EU)"
    ["BG"]="Europe"
    ["BH"]="Europe"
    ["BI"]="Default (EU)"
    ["BJ"]="Default (EU)"
    ["BL"]="Default (EU)"
    ["BM"]="USA"
    ["BN"]="Default (EU)"
    ["BO"]="USA"
    ["BQ"]="Europe"
    ["BR"]="Australia/New Zealand"
    ["BS"]="USA"
    ["BT"]="Default (EU)"
    ["BV"]="Europe"
    ["BW"]="Default (EU)"
    ["BY"]="Europe"
    ["BZ"]="Default (EU)"
    ["CA"]="USA"
    ["CC"]="Default (EU)"
    ["CD"]="Default (EU)"
    ["CF"]="Default (EU)"
    ["CG"]="Default (EU)"
    ["CH"]="Europe"
    ["CI"]="Default (EU)"
    ["CK"]="Australia/New Zealand"
    ["CL"]="Australia/New Zealand"
    ["CM"]="Default (EU)"
    ["CN"]="China"
    ["CO"]="USA"
    ["CR"]="Japan"
    ["CU"]="Default (EU)"
    ["CV"]="Default (EU)"
    ["CW"]="Europe"
    ["CX"]="Australia/New Zealand"
    ["CY"]="Europe"
    ["CZ"]="Europe"
    ["DE"]="Europe"
    ["DJ"]="Default (EU)"
    ["DK"]="Europe"
    ["DM"]="Default (EU)"
    ["DO"]="Australia/New Zealand"
    ["DZ"]="Hong Kong"
    ["EC"]="Australia/New Zealand"
    ["EE"]="Europe"
    ["EG"]="Europe"
    ["EH"]="Default (EU)"
    ["ER"]="Default (EU)"
    ["ES"]="Europe"
    ["ET"]="Default (EU)"
    ["FI"]="Europe"
    ["FJ"]="Australia/New Zealand"
    ["FK"]="Europe"
    ["FM"]="Australia/New Zealand"
    ["FO"]="Europe"
    ["FR"]="Europe"
    ["GA"]="Default (EU)"
    ["GB"]="Europe"
    ["GD"]="Default (EU)"
    ["GE"]="Europe"
    ["GF"]="Europe"
    ["GG"]="Europe"
    ["GH"]="Default (EU)"
    ["GI"]="Europe"
    ["GL"]="Default (EU)"
    ["GM"]="Default (EU)"
    ["GN"]="Default (EU)"
    ["GP"]="Default (EU)"
    ["GQ"]="Default (EU)"
    ["GR"]="Europe"
    ["GS"]="Europe"
    ["GT"]="USA"
    ["GU"]="USA"
    ["GW"]="Default (EU)"
    ["GY"]="Default (EU)"
    ["HK"]="Hong Kong"
    ["HM"]="Default (EU)"
    ["HN"]="USA"
    ["HR"]="Europe"
    ["HT"]="USA"
    ["HU"]="Europe"
    ["ID"]="Australia/New Zealand"
    ["IE"]="Europe"
    ["IL"]="Israel"
    ["IM"]="Europe"
    ["IN"]="India"
    ["IO"]="Europe"
    ["IQ"]="Europe"
    ["IR"]="Default (EU)"
    ["IS"]="Europe"
    ["IT"]="Europe"
    ["JE"]="Europe"
    ["JM"]="USA"
    ["JO"]="Europe"
    ["JP"]="Japan"
    ["KE"]="Default (EU)"
    ["KG"]="Default (EU)"
    ["KH"]="Default (EU)"
    ["KI"]="Australia/New Zealand"
    ["KM"]="Default (EU)"
    ["KN"]="USA"
    ["KP"]="Default (EU)"
    ["KR"]="Korea"
    ["KW"]="Europe"
    ["KY"]="USA"
    ["KZ"]="Europe"
    ["LA"]="Default (EU)"
    ["LB"]="Europe"
    ["LC"]="Default (EU)"
    ["LI"]="Europe"
    ["LK"]="Default (EU)"
    ["LR"]="Default (EU)"
    ["LS"]="Default (EU)"
    ["LT"]="Europe"
    ["LU"]="Europe"
    ["LV"]="Europe"
    ["LY"]="Europe"
    ["MA"]="China"
    ["MC"]="Europe"
    ["MD"]="Europe"
    ["ME"]="Europe"
    ["MF"]="Default (EU)"
    ["MG"]="Default (EU)"
    ["MH"]="Australia/New Zealand"
    ["MK"]="Europe"
    ["ML"]="Default (EU)"
    ["MM"]="Default (EU)"
    ["MN"]="Default (EU)"
    ["MO"]="Korea"
    ["MP"]="USA"
    ["MQ"]="Default (EU)"
    ["MR"]="Default (EU)"
    ["MS"]="Europe"
    ["MT"]="Europe"
    ["MU"]="Europe"
    ["MV"]="Europe"
    ["MW"]="Default (EU)"
    ["MX"]="Default (EU)"
    ["MY"]="Australia/New Zealand"
    ["MZ"]="Default (EU)"
    ["NA"]="Default (EU)"
    ["NC"]="Australia/New Zealand"
    ["NE"]="Default (EU)"
    ["NF"]="Australia/New Zealand"
    ["NG"]="Europe"
    ["NI"]="USA"
    ["NL"]="Europe"
    ["NO"]="Europe"
    ["NP"]="Default (EU)"
    ["NR"]="Australia/New Zealand"
    ["NU"]="Australia/New Zealand"
    ["NZ"]="Australia/New Zealand"
    ["OM"]="Europe"
    ["PA"]="USA"
    ["PE"]="Australia/New Zealand"
    ["PF"]="Australia/New Zealand"
    ["PG"]="Australia/New Zealand"
    ["PH"]="Europe"
    ["PK"]="Default (EU)"
    ["PL"]="Europe"
    ["PM"]="Default (EU)"
    ["PN"]="Europe"
    ["PR"]="USA"
    ["PT"]="Europe"
    ["PW"]="Australia/New Zealand"
    ["PY"]="Australia/New Zealand"
    ["QA"]="Europe"
    ["RE"]="Default (EU)"
    ["RO"]="Europe"
    ["RS"]="Europe"
    ["RU"]="Russia"
    ["RW"]="Default (EU)"
    ["SA"]="Europe"
    ["SB"]="Australia/New Zealand"
    ["SC"]="Default (EU)"
    ["SD"]="Default (EU)"
    ["SE"]="Europe"
    ["SG"]="Korea"
    ["SH"]="Europe"
    ["SI"]="Europe"
    ["SJ"]="Europe"
    ["SK"]="Europe"
    ["SL"]="Default (EU)"
    ["SM"]="Europe"
    ["SN"]="Default (EU)"
    ["SO"]="Default (EU)"
    ["SR"]="USA"
    ["SS"]="Default (EU)"
    ["ST"]="Default (EU)"
    ["SV"]="Australia/New Zealand"
    ["SX"]="Europe"
    ["SY"]="Default (EU)"
    ["SZ"]="Default (EU)"
    ["TC"]="USA"
    ["TD"]="Default (EU)"
    ["TF"]="Default (EU)"
    ["TG"]="Default (EU)"
    ["TH"]="Korea"
    ["TJ"]="Default (EU)"
    ["TK"]="Australia/New Zealand"
    ["TL"]="Default (EU)"
    ["TM"]="Europe"
    ["TN"]="Default (EU)"
    ["TO"]="Australia/New Zealand"
    ["TR"]="Europe"
    ["TT"]="USA"
    ["TV"]="Australia/New Zealand"
    ["TW"]="Korea"
    ["TZ"]="Default (EU)"
    ["UA"]="Europe"
    ["UG"]="Default (EU)"
    ["UM"]="USA"
    ["US"]="USA"
    ["UY"]="Australia/New Zealand"
    ["UZ"]="Europe"
    ["VA"]="Europe"
    ["VC"]="Default (EU)"
    ["VE"]="Australia/New Zealand"
    ["VG"]="USA"
    ["VI"]="USA"
    ["VN"]="Australia/New Zealand"
    ["VU"]="Australia/New Zealand"
    ["WF"]="Australia/New Zealand"
    ["WS"]="Australia/New Zealand"
    ["YE"]="Europe"
    ["YT"]="Default (EU)"
    ["ZA"]="Europe"
    ["ZM"]="Default (EU)"
    ["ZW"]="Default (EU)"
)

declare -A rf_region_integer_map=(
    ["Europe"]=0
    ["USA"]=1
    ["Australia/New Zealand"]=2
    ["Hong Kong"]=3
    ["India"]=5
    ["Israel"]=6
    ["Russia"]=7
    ["China"]=8
    ["USA (Long Range)"]=9
    ["Europe (Long Range)"]=11
    ["Japan"]=32
    ["Korea"]=33
    ["Default (EU)"]=255
)

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
            bashio::log.fatal "configuration in order to start the app."
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

# Migrate any keys in the legacy format (e.g. "0x00, 0x01, 0x02, ...") to the new format ("000102...")
for key in "s0_legacy_key" "s2_access_control_key" "s2_authenticated_key" "s2_unauthenticated_key" "lr_s2_access_control_key" "lr_s2_authenticated_key"; do
    network_key=$(bashio::config "${key}")
    if [[ "${network_key}" =~ ^0x[0-9A-Fa-f]{2}(,\ ?0x[0-9A-Fa-f]{2}){15}$ ]]; then
        bashio::log.info "Migrating ${key} from legacy format to new format..."
        network_key="${network_key//0x/}"
        network_key="${network_key//[, ]/}"
        network_key=$(bashio::string.upper "${network_key}")
        bashio::addon.option "${key}" "${network_key}"
        flush_to_disk=1
    fi
done

# Validate that no keys are using the example from the docs and generate new random
# keys for any missing keys.
for key in "s0_legacy_key" "s2_access_control_key" "s2_authenticated_key" "s2_unauthenticated_key" "lr_s2_access_control_key" "lr_s2_authenticated_key"; do
    network_key=$(bashio::config "${key}")
    network_key_upper=$(bashio::string.upper "${network_key}")
    if [ "${network_key_upper}" == "${DOCS_EXAMPLE_KEY_1}" ] || [ "${network_key_upper}" == "${DOCS_EXAMPLE_KEY_2}" ] || [ "${network_key_upper}" == "${DOCS_EXAMPLE_KEY_3}" ] || [ "${network_key_upper}" == "${DOCS_EXAMPLE_KEY_4}" ] || [ "${network_key_upper}" == "${DOCS_EXAMPLE_KEY_5}" ] || [ "${network_key_upper}" == "${DOCS_EXAMPLE_KEY_6}" ]; then
        bashio::log.fatal
        bashio::log.fatal "The app detected that the Z-Wave network key used"
        bashio::log.fatal "is from the documented example."
        bashio::log.fatal
        bashio::log.fatal "Using this key is insecure, because it is publicly"
        bashio::log.fatal "listed in the documentation."
        bashio::log.fatal
        bashio::log.fatal "Please check the app documentation on how to"
        bashio::log.fatal "create your own, secret, \"${key}\" and replace"
        bashio::log.fatal "the one you have configured."
        bashio::log.fatal
        bashio::log.fatal "Click on the \"Documentation\" tab in the Z-Wave JS"
        bashio::log.fatal "app panel for more information."
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
lr_s2_access_control=$(bashio::config "lr_s2_access_control_key")
lr_s2_authenticated=$(bashio::config "lr_s2_authenticated_key")

if ! bashio::config.has_value 'log_level'; then
    log_level=$(bashio::info.logging)
    bashio::log.info "No log level specified, falling back to Supervisor"
    bashio::log.info "log level (${log_level})..."
else
    log_level=$(bashio::config 'log_level')
fi

if bashio::config.equals 'rf_region' 'Automatic'; then
    country=$(bashio::supervisor.country)
    rf_region="${country_rf_region_map[$country]:-"Default (EU)"}"
    bashio::log.info "RF region set to Automatic: ${rf_region}"
else
    rf_region=$(bashio::config 'rf_region')
fi
rf_region_integer=${rf_region_integer_map["${rf_region}"]}

if [[ "${rf_region_integer}" -eq 255 ]]; then
    rf_json=$(jq -n '{autoPowerlevels: true}')
    bashio::log.info "Using default RF region settings"
else
    rf_json=$(jq -n --argjson region "${rf_region_integer}" '{region: $region, autoPowerlevels: true}')
    bashio::log.info "Setting RF region to (${rf_region})"
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
    bashio::log.warning "WARNING: If your controller becomes unresponsive, commands may start to fail and nodes may start to get marked as dead until the controller is able to recover on its own. If it doesn't recover on its own, you will need to restart the app manually to try to recover yourself."
    # Add NO_CONTROLLER_RECOVERY to presets array
    presets_array+=("NO_CONTROLLER_RECOVERY")
fi

if bashio::config.true 'disable_watchdog'; then
    bashio::log.info "Hardware watchdog disabled"
    # Add NO_WATCHDOG to presets array
    presets_array+=("NO_WATCHDOG")
fi

# Convert presets array to JSON string and add to config
if [[ ${#presets_array[@]} -eq 0 ]]; then
    presets="[]"
else
    presets="$(printf '%s\n' "${presets_array[@]}" | jq -R . | jq -s .)"
fi

log_to_file=$(bashio::config "log_to_file")
log_max_files=$(bashio::config "log_max_files")

# Generate config
bashio::var.json \
    s0_legacy "${s0_legacy}" \
    s2_access_control "${s2_access_control}" \
    s2_authenticated "${s2_authenticated}" \
    s2_unauthenticated "${s2_unauthenticated}" \
    lr_s2_access_control "${lr_s2_access_control}" \
    lr_s2_authenticated "${lr_s2_authenticated}" \
    log_level "${log_level}" \
    log_to_file "${log_to_file}" \
    log_max_files "${log_max_files}" \
    rf_json "${rf_json}" \
    soft_reset "^${soft_reset}" \
    presets "${presets}" |
    tempio \
        -template /usr/share/tempio/zwave_config.conf \
        -out /etc/zwave_config.json

# Create default settings.json in addon config directory if it doesn't exist
if ! bashio::fs.file_exists "/config/settings.json"; then
    bashio::log.info "Creating default settings.json..."
    # Disable MQTT by default
    mqtt=$(bashio::var.json \
        disabled "^true" \
        )
    # Disable Z-Wave JS UI logs by default
    gateway=$(bashio::var.json \
        logEnabled "^false" \
        logLevel info \
        logToFile "^false" \
        )

    bashio::var.json \
        gateway "^${gateway}" \
        mqtt "^${mqtt}" \
        > /config/settings.json
fi
