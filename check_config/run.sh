#!/usr/bin/env bashio
set -e

VERSION=$(bashio::config 'version')

# Generate install string
CMD="homeassistant"
if [ "${VERSION}" != "latest" ]; then
    CMD="homeassistant==${VERSION}"
fi

bashio::log.info "Installing Home Assistant: ${VERSION}..."
bashio::log.info "Please be patient, this might take a few minutes..."

# Install Home Assistant with the requested version
if ! PIP_OUTPUT="$(pip3 install --find-links "${WHEELS_LINKS}" "${CMD}")"; then
    bashio::log.error "An error occurred while installing Home Assistant:"
    bashio::log "${PIP_OUTPUT}"
    bashio::exit.nok
fi
INSTALLED_VERSION="$(pip freeze | grep homeassistant)"
bashio::log.info "Installed Home Assistant ${INSTALLED_VERSION##*=} in this add-on."

# Making an temporary copy of your configuration
bashio::log.info "Making a copy of your configuration for checking..."
cp -fr /config /tmp/config

# Start configuration check
bashio::log.info "Checking your configuration against this version..."
if ! HASS_OUTPUT="$(hass -c /tmp/config --script check_config)"; then
    # The configuration check exited with an error
    bashio::log.error "The configuration check did not pass!"
    bashio::log.error "See the output below for more details."
    bashio::log "${HASS_OUTPUT}"
    bashio::exit.nok
fi

# Scan configuration check output for occurrances of "ERROR"
if echo "${HASS_OUTPUT}" | grep -i ERROR > /dev/null; then
    # An "ERROR" occurance has been found, exit with an error
    bashio::log.error "Found an error in the log output of the check!"
    bashio::log.error "See the output below for more details."
    bashio::log "${HASS_OUTPUT}"
    bashio::exit.nok
fi

# You rock! <(*_*)>
bashio::log.info "Configuration check finished - no error found! :)"
