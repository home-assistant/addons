#!/bin/bash
# shellcheck disable=SC2244,SC1117
set -e

CONFIG_PATH=/data/options.json
SYSTEM_USER=/data/system_user.json
REQUEST=()
REQUEST_BODY=""

declare -A LOCAL_DB

## Functions

function http_ok() {
    echo -e "HTTP/1.1 200 OK\n"
    exit 0
}

function http_error() {
    echo -e "HTTP/1.1 400 Bad Request\n"
    exit 0
}


function create_userdb() {
    local logins=0
    local username=""
    local password=""
    local hass_pw=""
    local addons_pw=""

    logins=$(jq --raw-output '.logins | length' $CONFIG_PATH)
    for (( i=0; i < "$logins"; i++ )); do
        username="$(jq --raw-output ".logins[$i].username" $CONFIG_PATH)"
        password="$(jq --raw-output ".logins[$i].password" $CONFIG_PATH)"

        LOCAL_DB["${username}"]="${password}"
    done

    # Add system user to DB
    hass_pw=$(jq --raw-output '.homeassistant.password' $SYSTEM_USER)
    addons_pw=$(jq --raw-output '.addons.password' $SYSTEM_USER)

    LOCAL_DB['homeassistant']="${hass_pw}"
    LOCAL_DB['addons']="${addons_pw}"
}


function read_request() {
    local content_length=0

    while read -r line; do
        line="${line%%[[:cntrl:]]}"

        if [[ "${line}" =~ Content-Length ]]; then
            content_length="${line//[!0-9]/}"
        fi

        if [ -z "$line" ]; then
            if [ "${content_length}" -gt 0 ]; then
                read -r -n "${content_length}" REQUEST_BODY
            fi
            break
        fi

        REQUEST+=("$line")
    done
}



function get_var() {
    local variable=$1
    local value=""
    urldecode() { : "${*//+/ }"; echo -e "${_//%/\\x}"; }

    # shellcheck disable=SC2001
    value="$(echo "$REQUEST_BODY" | sed "s/.*$variable=\([^&]*\).*/\1/g")"
    urldecode "${value}"
}


## MAIN ##

read_request

# This feature currently not implemented, we response with 200
if [[ "${REQUEST[0]}" =~ /superuser ]] || [[ "${REQUEST[0]}" =~ /acl ]]; then
    http_ok
fi

# We read now the user data
create_userdb

username="$(get_var username)"
password="$(get_var password)"

# If local user
if [ "${LOCAL_DB["${username}"]}" == "${password}" ]; then
    echo "[INFO] found ${username} on local database" >&2
    http_ok
elif [ ${LOCAL_DB["${username}"]+_} ]; then
    echo "[WARN] Not found ${username} on local database" >&2
    http_error
fi

# Ask HomeAssistant Auth
auth_header="X-Hassio-Key: ${HASSIO_TOKEN}"
content_type="Content-Type: application/x-www-form-urlencoded"

if curl -s -f -X POST -d "${REQUEST_BODY}" -H "${content_type}" -H "${auth_header}" http://hassio/auth > /dev/null; then
    echo "[INFO] found ${username} on Home Assistant" >&2
    http_ok
fi

echo "[ERROR] Auth error with ${username}" >&2
http_error
