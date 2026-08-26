#!/usr/bin/with-contenv bashio
# shellcheck shell=bash
# ==============================================================================
# Configure OTBR depending on add-on settings
# ==============================================================================

ot-ctl trel enable

# ------------------------------------------------------------------
# Sync TREL UDP port into nftables set ip6 otbr trel_ports
# (rules match @trel_ports; empty set = no TREL match until populated)
# ------------------------------------------------------------------
sync_trel_port_to_firewall() {
    local trel_port=""
    local i

    # Wait for ot-ctl to report a numeric TREL port
    for i in {1..30}; do
        trel_port="$(ot-ctl trel port 2>/dev/null | head -n1 | tr -d '[:space:]')"
        if [[ "${trel_port}" =~ ^[0-9]+$ ]]; then
            break
        fi
        trel_port=""
        sleep 1
    done

    if [[ ! "${trel_port}" =~ ^[0-9]+$ ]]; then
        bashio::log.warning "TREL port not available yet; leaving nft trel_ports empty"
        nft flush set ip6 otbr trel_ports 2>/dev/null || true
        return 0
    fi

    # Firewall table/set may not exist yet if this runs before otbr firewall setup
    if ! nft list set ip6 otbr trel_ports >/dev/null 2>&1; then
        bashio::log.warning "nft set ip6 otbr trel_ports not found yet; will not sync port ${trel_port}"
        return 0
    fi

    if nft flush set ip6 otbr trel_ports \
        && nft add element ip6 otbr trel_ports "{ ${trel_port} }"; then
        bashio::log.info "Synced TREL port ${trel_port} into nft set ip6 otbr trel_ports"
    else
        bashio::log.error "Failed to update nft set ip6 otbr trel_ports with port ${trel_port}"
        return 1
    fi
}

sync_trel_port_to_firewall

if bashio::config.true 'nat64'; then
    bashio::log.info "Enabling NAT64."
    ot-ctl nat64 enable
    ot-ctl dns server upstream enable
fi

mdns_localhostname="$(hostname)-otbr"
bashio::log.info "Setting OpenThread mDNS local hostname to ${mdns_localhostname}."
ot-ctl mdns localhostname "${mdns_localhostname}"
ot-ctl mdns enable

# Enable border routing
ot-ctl br enable

# ==============================================================================
# Custom OMR Prefix + Preference
# ==============================================================================
OMR_PREF=$(bashio::config 'custom_omr_priority')
if bashio::config.has_value 'custom_omr_prefix'; then
    DESIRED_PREFIX=$(bashio::config 'custom_omr_prefix')

    if [[ -n "$DESIRED_PREFIX" ]]; then
        bashio::log.info "Custom OMR prefix requested: ${DESIRED_PREFIX}"

        # Wait until ot-ctl is ready
        for i in {1..40}; do
            if ot-ctl state >/dev/null 2>&1; then
                break
            fi
            sleep 1
        done

        # Check if already set correctly
        CURRENT=$(ot-ctl br omrprefix local 2>/dev/null | awk '{print $2}' || true)

        if [[ "$CURRENT" == "$DESIRED_PREFIX" ]]; then
            bashio::log.info "✅ Custom OMR prefix already set to ${DESIRED_PREFIX}"
        else
            bashio::log.info "Applying custom OMR prefix: ${DESIRED_PREFIX}"

            if ot-ctl br omrconfig custom "${DESIRED_PREFIX}" "${OMR_PREF}"; then
                bashio::log.info "✅ Successfully applied custom OMR prefix: ${DESIRED_PREFIX} (priority ${OMR_PREF})"
            else
                bashio::log.error "❌ Failed to apply custom OMR prefix"
                return 11
            fi
        fi
    fi
fi

if ot-ctl br rioprf "${OMR_PREF}"; then
	bashio::log.info "✅ Successfully applied rioprf: ${OMR_PREF}"
else
	bashio::log.error "❌ Failed to apply custom rioprf value"
fi

if ot-ctl br routeprf "${OMR_PREF}"; then
	bashio::log.info "✅ Successfully applied routeprf: ${OMR_PREF}"
else
	bashio::log.error "❌ Failed to apply custom routeprf value"
fi

# Configure the leader weight for this border router if a custom value was specified.
if bashio::config.has_value 'leader_weight'; then
    LEADER_WEIGHT=$(bashio::config 'leader_weight')
    if ot-ctl leaderweight $LEADER_WEIGHT; then
    	bashio::log.info "✅ Successfully applied leader weight: ${LEADER_WEIGHT}"
    else
    	bashio::log.error "❌ Failed to apply custom leader weight"
    	return 12
    fi
fi

# To avoid asymmetric link quality the TX power from the controller should not
# exceed that of what other Thread routers devices typically use.
ot-ctl txpower 6

if ot-ctl thread start; then
	bashio::log.info "✅ Successfully started Thread radio"
else
	bashio::log.info "❌ Failed to start Thread radio"
	return 15
fi

# Re-sync TREL after br enable (port can change once border routing is up)
sync_trel_port_to_firewall
