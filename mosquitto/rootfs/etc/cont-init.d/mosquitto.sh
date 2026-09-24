#!/usr/bin/with-contenv bashio
# shellcheck shell=bash
# ==============================================================================
# Configures mosquitto
# ==============================================================================
readonly ACL="/etc/mosquitto/acl"
readonly PW="/etc/mosquitto/pw"
readonly SYSTEM_USER="/data/system_user.json"
declare acl_file
declare acl_user
declare cafile
declare certfile
declare discovery_password
declare keyfile
declare log_dest
declare log_type
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

# Enforce a user-provided ACL file. go-auth answers every ACL check and the
# first answer wins, so the builtin `acl_file` directive is never consulted
# with mosquitto 2.1 (#4571). When `acl_file` is set, go-auth reads the rules
# from it and the internal HTTP endpoints stop granting everything; the
# internal users keep unrestricted access, as Home Assistant requires.
if bashio::config.has_value 'acl_file'; then
  acl_file="/share/$(bashio::config 'acl_file')"
  if ! bashio::fs.file_exists "${acl_file}"; then
    bashio::exit.nok "ACL file ${acl_file} not found"
  fi
  bashio::log.info "Enforcing ACL file ${acl_file}"
  # go-auth only applies `user` blocks to users in its password file, and
  # evaluates every deny rule before any grant. Warn about both limits.
  while read -r acl_user; do
    if ! grep -q "^${acl_user}:" "${PW}"; then
      bashio::log.warning "ACL rules for '${acl_user}' are ignored: only users from the logins option can have per-user rules, use a 'pattern' rule with %u instead"
    fi
  done < <(awk '$1 == "user" {print $2}' "${acl_file}" | sort -u)
  if awk '$1 == "user" {in_user = 1} !in_user && ($1 == "topic" || $1 == "pattern") && $2 == "deny" {found = 1} $1 == "pattern" && $2 == "deny" {found = 1} END {exit !found}' "${acl_file}"; then
    bashio::log.warning "Deny rules outside a 'user' block also apply to the internal homeassistant and addons users"
  fi
  {
    cat "${acl_file}"
    echo ""
    echo "user homeassistant"
    echo "topic readwrite #"
    echo ""
    echo "user addons"
    echo "topic readwrite #"
  } > "${ACL}"
fi

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

# Get log options as raw JSON types for tempio
options=$(bashio::addon.config)
log_dest=$(jq -c ".log_dest" <<<"$options")
log_type=$(jq -c ".log_type" <<<"$options")

# Generate mosquitto configuration.
bashio::var.json \
  cafile "${cafile}" \
  certfile "${certfile}" \
  customize "^$(bashio::config 'customize.active')" \
  customize_folder "$(bashio::config 'customize.folder')" \
  keyfile "${keyfile}" \
  log_dest "^${log_dest}" \
  log_type "^${log_type}" \
  require_certificate "^$(bashio::config 'require_certificate')" \
  ssl "^${ssl}" \
  debug "^$(bashio::config 'debug')" \
  | tempio \
    -template /usr/share/tempio/mosquitto.gtpl \
    -out /etc/mosquitto/mosquitto.conf
