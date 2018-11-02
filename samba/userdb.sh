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

    template="${template/"%%COLOR%%"/"$message_color"}"
    template="${template/"%%MESSAGE%%"/"$message"}"

    # Output page
    echo -e "HTTP/1.1 200 OK\n"
    echo "${template}"
    exit 0
}

function http_auth() {
    echo "HTTP/1.1 401 Unauthorized"
    echo -e "WWW-Authenticate: Basic realm=\"Home Assistant Auth\"\n"
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


function add_db() {
    username="$(get_var username)"
    password1="$(get_var password1)"
    password2="$(get_var password2)"

    if [ "${password1}" != "${password2}" ]; then
        http_page "Password not equal!" red
    fi
    password="${password1}"

    addgroup "${username}"
    adduser -D -H -G "${username}" -s /bin/false "${username}"
    echo -e "${password}\n${password}" | smbpasswd -a -s -c /etc/smb.conf "${username}"

    http_page Success green
}


function del_db() {
    username="$(get_var username)"

    deluser "${username}"
    smbpasswd -x -s -c /etc/smb.conf "${username}"

    http_page Success green
}


function get_authorization() {
    for ((i=0; i < ${#REQUEST[@]}; ++i)); do
        if [[ "${REQUEST[$i]}" =~ Authorization ]]; then
            echo "${REQUEST[$i]}"
        fi
    done
}


function check_authorization() {
    auth_header="X-Hassio-Key: ${HASSIO_TOKEN}"
    authorization="$(get_authorization)"

    # Check if allow to add user
    if [ -z "${authorization}" ]; then
        http_auth
    fi

    # Ask HomeAssistant Auth
    if ! curl -q -f -X POST -H "${authorization}" -H "${auth_header}" http://hassio/auth > /dev/null; then
        http_auth
    fi
}


## MAIN ##

read_request
check_authorization

# Add user request?
if [[ "${REQUEST[0]}" =~ /add ]] && [[ -n "${REQUEST_BODY}" ]]; then
    add_db
fi

# Remove user request?
if [[ "${REQUEST[0]}" =~ /del ]] && [[ -n "${REQUEST_BODY}" ]]; then
    remove_db
fi

http_page
