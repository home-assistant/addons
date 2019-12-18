#!/usr/bin/env bashio
set -e

DIRSFIRST=$(bashio::config 'dirsfirst')
ENFORCE_BASEPATH=$(bashio::config 'enforce_basepath')
IGNORE_PATTERN="$(bashio::config 'ignore_pattern | join(",")')"

# If any SSH key files are defined in the configuration options, add them for use by git
if bashio::config.has_value "ssh_keys"; then
  # Start the SSH agent
  bashio::log.info "Starting SSH agent"
  eval "$(ssh-agent -s)"

  # Add the keys defined in the configuration options
  while read -r filename; do
    if bashio::fs.file_exists "${filename}"; then
      bashio::log.info "Adding SSH private key file \"${filename}\""
      ssh-add -q "${filename}"
    else
      bashio::log.error "SSH key file \"${filename}\" not found"
    fi
  done <<< "$(bashio::config 'ssh_keys')"

  # Disable strict host key checking
  mkdir -p ~/.ssh
  {
    echo "Host *"
    echo "    StrictHostKeyChecking no"
  } > ~/.ssh/config
fi

# Setup and run configurator
export HC_HASS_API_PASSWORD="${HASSIO_TOKEN}"
export HC_DIRFIRST="${DIRSFIRST}"
export HC_ENFORCE_BASEPATH="${ENFORCE_BASEPATH}"
export HC_IGNORE_PATTERN="${IGNORE_PATTERN}"

exec hass-configurator /etc/configurator.conf
