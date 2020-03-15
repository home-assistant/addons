#!/usr/bin/env bash
# ==============================================================================
# Home Assistant Add-ons: Lets Encrypt Functions
# These are functions to support the Lets Encrypt Addon.
# ==============================================================================

# Stores the location of this library
readonly __LETSENCRYPT_DEFAULT_CERT_DIR="/data/letsencrypt"
readonly __LETSENCRYPT_DEFAULT_WORK_DIR="/data/workdir"



declare __LETSENCRYPT_CERT_DIR=${LETSENCRYPT_CERT_DIR:-${__LETSENCRYPT_DEFAULT_CERT_DIR}}
declare __LETSENCRYPT_WORK_DIR=${LETSENCRYPT_WORK_DIR:-${__LETSENCRYPT_DEFAULT_WORK_DIR}}

# ------------------------------------------------------------------------------
# Gets the renewal option setting for the renew command
# ------------------------------------------------------------------------------
function letsencrypt::renewal_options() {
    if bashio::config.true 'dev_force_renewal'; then
        bashio::log.warning "Forcing renewal on every attempt."
        echo -n -e "--force-renewal"
    else
        echo -n -e ""
    fi
}

# ------------------------------------------------------------------------------
# Gets the server option setting all the certbot commands
# This is to allow for a development environment using the lets encrypt staging
# server
# ------------------------------------------------------------------------------
function letsencrypt::server_options() {
    if bashio::config.true 'dev_use_staging'; then
        bashio::log.warning "Using Lets Encrypt Staging Server. A valid certificate will not be issued"
        echo -n -e "https://acme-staging-v02.api.letsencrypt.org/directory"
    else
        echo -n -e "https://acme-v02.api.letsencrypt.org/directory"
    fi
}

# ------------------------------------------------------------------------------
# Gets the certificate directory to use with the certbot
# ------------------------------------------------------------------------------
function letsencrypt::cert_dir() {
    echo -n -e "${__LETSENCRYPT_CERT_DIR}"
}

# ------------------------------------------------------------------------------
# Gets the working directory to use with the certbot
# ------------------------------------------------------------------------------
function letsencrypt::work_dir() {
    echo -n -e "${__LETSENCRYPT_WORK_DIR}"
}

# ------------------------------------------------------------------------------
# Converts a 24hr time (hh:mm) to a crontab entry
#
# Arguments:
#   $1 the 24hr time (hh:mm) to convert
# ------------------------------------------------------------------------------
function letsencrypt::crontab_convert() {
    local renewal_check_time=${1:-'00:00'}
    bashio::log.trace "${FUNCNAME[0]}"
    IFS=':' read -ra RENEWAL_TIME <<< "${renewal_check_time}"
    hour="${RENEWAL_TIME[0]}"
    minute="${RENEWAL_TIME[1]}"
    echo -n -e "${minute} ${hour} * * *"
}