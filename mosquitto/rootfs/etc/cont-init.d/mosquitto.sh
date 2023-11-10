#!/usr/bin/with-contenv bashio
# ==============================================================================
# Configures mosquitto
# ==============================================================================
readonly ACL="/etc/mosquitto/acl"
readonly PW="/etc/mosquitto/pw"
readonly SYSTEM_USER="/data/system_user.json"
declare cafile
declare certfile
declare discovery_password
declare keyfile
declare password
declare service_password
declare ssl
declare username

# Read or create system account data
if ! bashio::fs.file_exists "${SYSTEM_USER}"; then
  discovery_password="$(pwgen 64 1)"
  service_password="$(pwgen 64 1)"

  # Store it for future use
  bashio::var.json \
    homeassistant "^$(bashio::var.json password "${discovery_password}")" \
    addons "^$(bashio::var.json password "${service_password}")" \
    > "${SYSTEM_USER}"
else
  # Read the existing values
  discovery_password=$(bashio::jq "${SYSTEM_USER}" ".homeassistant.password")
  service_password=$(bashio::jq "${SYSTEM_USER}" ".addons.password")
fi

# Set up discovery user
password=$(pw -p "${discovery_password}")
echo "homeassistant:${password}" >> "${PW}"
echo "user homeassistant" >> "${ACL}"

# Set up service user
password=$(pw -p "${service_password}")
echo "addons:${password}" >> "${PW}"
echo "user addons" >> "${ACL}"

# Set username and password for the broker
for login in $(bashio::config 'logins|keys'); do
  bashio::config.require.username "logins[${login}].username"
  bashio::config.require.password "logins[${login}].password"

  username=$(bashio::config "logins[${login}].username")
  password=$(bashio::config "logins[${login}].password")

  bashio::log.info "Setting up user ${username}"
  if ! bashio::config.true "logins[${login}].password_pre_hashed"
  then
      password=$(pw -p "${password}")
  else
      bashio::log.info "Using pre-hashed password for ${username}"
  fi
  echo "${username}:${password}" >> "${PW}"
  echo "user ${username}" >> "${ACL}"
done

keyfile="/ssl/$(bashio::config 'keyfile')"
certfile="/ssl/$(bashio::config 'certfile')"
cafile="/ssl/$(bashio::config 'cafile')"
if bashio::fs.file_exists "${certfile}" \
  && bashio::fs.file_exists "${keyfile}";
then
  bashio::log.info "Certificates found: SSL is available"
  ssl="true"
  if ! bashio::fs.file_exists "${cafile}"; then
    cafile="${certfile}"
  fi
else
  bashio::log.info "SSL is not enabled"
  ssl="false"
fi

# Generate mosquitto configuration.
bashio::var.json \
  cafile "${cafile}" \
  certfile "${certfile}" \
  customize "^$(bashio::config 'customize.active')" \
  customize_folder "$(bashio::config 'customize.folder')" \
  keyfile "${keyfile}" \
  require_certificate "^$(bashio::config 'require_certificate')" \
  ssl "^${ssl}" \
  debug "^$(bashio::config 'debug')" \
  | tempio \
    -template /usr/share/tempio/mosquitto.gtpl \
    -out /etc/mosquitto/mosquitto.conf
