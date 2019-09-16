#!/usr/bin/env bashio
set -e

DIRSFIRST=$(bashio::config 'dirsfirst')
ENFORCE_BASEPATH=$(bashio::config 'enforce_basepath')
IGNORE_PATTERN="$(bashio::jq "/data/options.json" ".ignore_pattern")"
WAIT_PIDS=()

# If any SSH key files are defined in the configuration options, add them for use by git
if bashio::config.has_value "ssh_keys"; then
  # Start the SSH agent
  bashio::log.info "Starting SSH agent"
  eval "$(ssh-agent -s)"

  # Add the keys defined in the configuration options
  while read -r filename; do
    if bashio::fs.file_exists "$filename"; then
      bashio::log.info "Adding SSH private key file \"$filename\""
      ssh-add -q "$filename"
    else
      bashio::log.error "SSH key file \"$filename\" not found"
    fi
  done <<< "$(bashio::config 'ssh_keys')"

  # Disable strict host key checking
  mkdir -p ~/.ssh
  echo "Host *
    StrictHostKeyChecking no" > ~/.ssh/config
fi

# Setup and run Frontend
sed -i "s/%%PORT%%/8080/g" /etc/nginx/nginx-ingress.conf
sed -i "s/%%PORT_INGRESS%%/8099/g" /etc/nginx/nginx-ingress.conf

nginx -c /etc/nginx/nginx-ingress.conf &
WAIT_PIDS+=($!)

# Setup and run configurator
sed -i "s/%%TOKEN%%/${HASSIO_TOKEN}/g" /etc/configurator.conf
sed -i "s/%%DIRSFIRST%%/${DIRSFIRST}/g" /etc/configurator.conf
sed -i "s/%%ENFORCE_BASEPATH%%/${ENFORCE_BASEPATH}/g" /etc/configurator.conf
sed -i "s/%%IGNORE_PATTERN%%/${IGNORE_PATTERN}/g" /etc/configurator.conf

hass-configurator /etc/configurator.conf &
WAIT_PIDS+=($!)

# Register stop
function stop_addon() {
    bashio::log.debug "Kill Processes..."
    kill -15 "${WAIT_PIDS[@]}"
    wait "${WAIT_PIDS[@]}"
    bashio::log.debug "Done."
}
trap "stop_addon" SIGTERM SIGHUP

# Wait until all is done
bashio::log.info "Add-on running"
wait "${WAIT_PIDS[@]}"
