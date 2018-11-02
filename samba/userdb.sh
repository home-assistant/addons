#!/bin/bash
set -e

REQUEST=()
REQUEST_BODY=""

## Functions

function http_page() {
    local message=$1
    local message_color=$2
    local template=""

    template="$(cat /usr/share/userdb.html)"

    template="${template/%%COLOR%%/"$message_color"}"
    template="${template/%%MESSAGE%%/"$message"}"

    # Output page
    echo -e "HTTP/1.1 200 OK\n"
    echo "${template}"
    echo -e "\n"
    exit 0
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

    value="$(echo "$REQUEST_BODY" | sed "s/.*$variable=\([^&]*\).*/\1/g")"
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
if [[ "${REQUEST[0]}" =~ /sync ]] && [[ -n "${REQUEST_BODY}" ]]; then
    try_login
fi

http_page
