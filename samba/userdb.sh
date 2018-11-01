#!/bin/bash
set -e

CONFIG_PATH=/data/options.json
SYSTEM_USER=/data/system_user.json
REQUEST=()
REQUEST_VAR=""

## Functions

function http_page() {
    echo -e "HTTP/1.1 200 OK\n\n"
    exit 0
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


function try_login() {
    username="$(get_var username)"
    password="$(get_var password)"

    # Ask HomeAssistant Auth
    json_data="{\"username\": \"${username}\", \"password\": \"${password}\"}"
    auth_header="X-Hassio_key: ${HASSIO_TOKEN}"

    if curl -q -f -X POST -d "${json_data}" -H "${auth_header}" http://hassio/auth; then
        http_page "Success" green
    else
        http_page "Wrong login" red
    fi
}


## MAIN ##

read_request

# User post request?
if [[ "${REQUEST[0]}" =~ /auth ]] && [[ -n "${REQUEST_VAR}" ]]; then
    try_login
fi

http_page
