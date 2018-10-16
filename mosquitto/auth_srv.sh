#!/bin/bash
set -e

CONFIG_PATH=/data/options.json
SYSTEM_USER=/data/system_user.json
REQUEST=()
REQUEST_VAR=""

declare -A LOCAL_DB

## Functions

function http_ok() {
    echo -e "HTTP/1.1 200 OK\n\n"
    exit 0
}

function http_error() {
    echo -e "HTTP/1.1 400 Bad Request\n\n"
    exit 1
}


function create_userdb() {
    local logins=0
    local username=""
    local password=""
    local hass_pw=""
    local addons_pw=""

    logins=$(jq --raw-output '.logins | length' $CONFIG_PATH)
    for (( i=0; i < "$logins"; i++ )); do
        username=$(jq --raw-output ".logins[$i].username" $CONFIG_PATH)
        password=$(jq --raw-output ".logins[$i].password" $CONFIG_PATH)

        LOCAL_DB[${username}]=${password}
    done

    # Add system user to DB
    hass_pw=$(jq --raw-output '.homeassistant.password' $SYSTEM_USER)
    addons_pw=$(jq --raw-output '.addons.password' $SYSTEM_USER)

    LOCAL_DB['homeassistant']=${hass_pw}
    LOCAL_DB['addons']=${addons_pw}
}


function read_request() {
    while read -r line; do
        line=${line%%$'\r'}

        # If we've reached the end of the headers, break.
        if [ -z "$line" ]; then
            break
        fi

        # If that is the payload?
        if [[ "$line" =~ username ]] && [[ "$line" =~ password ]]; then
            REQUEST_VAR="${line}"
        fi

        REQUEST+=("$line")
    done
}


function get_var() {
    local variable=$1
    local value=""
    urldecode() { : "${*//+/ }"; echo -e "${_//%/\\x}"; }

    value="$(echo "$REQUEST_VAR" | sed -i "s/.*$variable=\([^&]*\).*/\1/g")"
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
if [ "${LOCAL_DB[${username}]}" == "${password}" ]; then
    http_ok
elif [ ${LOCAL_DB[${username}]+_} ]; then
    http_error
fi

# Ask HomeAssistant Auth
json_data="{\"username\": \"${username}\", \"password\": \"${password}\"}"
auth_header="X-Hassio_key: ${HASSIO_TOKEN}"

if curl -q -f -X POST -d "${json_data}" -H "${auth_header}" http://hassio/auth; then
    http_ok
fi

http_error
