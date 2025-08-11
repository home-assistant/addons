#!/bin/bash
# shellcheck disable=SC2034
set -e

CONFIG_PATH=/data/options.json

SYS_TOKEN=$(jq --raw-output '.token' $CONFIG_PATH)
SYS_CERTFILE=$(jq --raw-output '.lets_encrypt.certfile' $CONFIG_PATH)
SYS_KEYFILE=$(jq --raw-output '.lets_encrypt.keyfile' $CONFIG_PATH)

# https://github.com/lukas2511/dehydrated/blob/master/docs/examples/hook.sh

deploy_challenge() {
    local DOMAIN="${1}" TOKEN_FILENAME="${2}" TOKEN_VALUE="${3}" ALIAS
    ALIAS="$(jq --raw-output --exit-status "[.aliases[]|{(.domain):.alias}]|add.\"$DOMAIN\"" $CONFIG_PATH)" || ALIAS="$DOMAIN"

	bashio::log.info "Processing domain: $DOMAIN"

    # This hook is called once for every domain that needs to be
    # validated, including any alternative names you may have listed.
    #
    # Parameters:
    # - DOMAIN
    #   The domain name (CN or subject alternative name) being
    #   validated.
    # - TOKEN_FILENAME
    #   The name of the file containing the token to be served for HTTP
    #   validation. Should be served by your web server as
    #   /.well-known/acme-challenge/${TOKEN_FILENAME}.
    # - TOKEN_VALUE
    #   The token value that needs to be served for validation. For DNS
    #   validation, this is what you want to put in the _acme-challenge
    #   TXT record. For HTTP validation it is the value that is expected
    #   be found in the $TOKEN_FILENAME file.

	curl -s "https://www.duckdns.org/update?domains=$ALIAS&token=$SYS_TOKEN&txt=$TOKEN_VALUE"
	timeout 120s bash -c -- "
		while ! dig -t txt \"_acme-challenge.$ALIAS\" | grep -F \"$TOKEN_VALUE\" > /dev/null; do
			sleep 5;
		done
	"
}

clean_challenge() {
    local DOMAIN="${1}" TOKEN_FILENAME="${2}" TOKEN_VALUE="${3}" ALIAS
    ALIAS="$(jq --raw-output --exit-status "[.aliases[]|{(.domain):.alias}]|add.\"$DOMAIN\"" $CONFIG_PATH)" || ALIAS="$DOMAIN"

    # This hook is called after attempting to validate each domain,
    # whether or not validation was successful. Here you can delete
    # files or DNS records that are no longer needed.
    #
    # The parameters are the same as for deploy_challenge.

	curl -s "https://www.duckdns.org/update?domains=$ALIAS&token=$SYS_TOKEN&txt=removed&clear=true"
}

deploy_cert() {
    local DOMAIN="${1}" KEYFILE="${2}" CERTFILE="${3}" FULLCHAINFILE="${4}" CHAINFILE="${5}" TIMESTAMP="${6}"

    # This hook is called once for each certificate that has been
    # produced. Here you might, for instance, copy your new certificates
    # to service-specific locations and reload the service.
    #
    # Parameters:
    # - DOMAIN
    #   The primary domain name, i.e. the certificate common
    #   name (CN).
    # - KEYFILE
    #   The path of the file containing the private key.
    # - CERTFILE
    #   The path of the file containing the signed certificate.
    # - FULLCHAINFILE
    #   The path of the file containing the full certificate chain.
    # - CHAINFILE
    #   The path of the file containing the intermediate certificate(s).
    # - TIMESTAMP
    #   Timestamp when the specified certificate was created.

     cp -f "$FULLCHAINFILE" "/ssl/$SYS_CERTFILE"
     cp -f "$KEYFILE" "/ssl/$SYS_KEYFILE"
}


HANDLER="$1"; shift
if [[ "${HANDLER}" =~ ^(deploy_challenge|clean_challenge|deploy_cert)$ ]]; then
  "$HANDLER" "$@"
fi
