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


function try_login() {
    auth_header="X-Hassio-Key: ${HASSIO_TOKEN}"
    content_type="Content-Type: application/x-www-form-urlencoded"

    # Ask HomeAssistant Auth
    if curl -q -f -X POST -d "${REQUEST_BODY}" -H "${content_type}" -H "${auth_header}" http://hassio/auth; then
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
