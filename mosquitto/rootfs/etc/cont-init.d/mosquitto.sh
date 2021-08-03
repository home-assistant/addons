#!/usr/bin/with-contenv bashio
# ==============================================================================
# Configures mosquitto
# ==============================================================================
readonly DB="/etc/mosquitto/mosquitto.sqlite"
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

sqlite3 "${DB}" "drop table if exists users; create table users(username varchar(100), pw varchar(100));"
# Set up discovery user
password=$(np -p "${discovery_password}")
sqlite3 "${DB}" "insert into users values('homeassistant','${password}');"

# Set up service user
password=$(np -p "${service_password}")
sqlite3 "${DB}" "insert into users values('addons','${password}');"

# Set username and password for the broker
for login in $(bashio::config 'logins|keys'); do
  bashio::config.require.username "logins[${login}].username"
  bashio::config.require.password "logins[${login}].password"

  username=$(bashio::config "logins[${login}].username")
  password=$(bashio::config "logins[${login}].password")

  bashio::log.info "Setting up user ${username}"
  password=$(np -p "${password}")
  sqlite3 "${DB}" "insert into users values('${username}','${password}');"
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
  | tempio \
    -template /usr/share/tempio/mosquitto.gtpl \
    -out /etc/mosquitto/mosquitto.conf
