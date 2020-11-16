#!/bin/bash
# shellcheck disable=SC2034
set -e

CONFIG_PATH=/data/options.json
CF_API=https://api.cloudflare.com/client/v4

SYS_API_TOKEN=$(jq --raw-output '.cloudflare_api_token' $CONFIG_PATH)
SYS_CERTFILE=$(jq --raw-output '.lets_encrypt.certfile' $CONFIG_PATH)
SYS_KEYFILE=$(jq --raw-output '.lets_encrypt.keyfile' $CONFIG_PATH)
SYS_TTL=$(jq --raw-output '.seconds // 300' $CONFIG_PATH)

if [[ "${SYS_API_TOKEN}" = "null" ]];
then
    >&2 echo "CloudFlare credentials missing"
    exit 1
fi
# https://github.com/lukas2511/dehydrated/blob/master/docs/examples/hook.sh

deploy_challenge() {
    local DOMAIN="${1}" TOKEN_FILENAME="${2}" TOKEN_VALUE="${3}" ZONE ZONE_ID

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

    if ! ZONE=$(find_zone_by_fqdn "${DOMAIN}");
    then
        >&2 echo "Unable to find zone apex"
    fi

    if ! ZONE_ID=$(find_zone_id "${ZONE}");
    then
        >&2 echo "Unable to find zone id"
    fi

    clean_txt_record "${ZONE_ID}" "${DOMAIN}" "${TOKEN_VALUE}"

    curl -s -f -X POST "${CF_API}/zones/${ZONE_ID}/dns_records" \
         -H "Content-Type: application/json" \
         -H "Authorization: Bearer ${SYS_API_TOKEN}" \
         --data "{\"type\":\"TXT\",\"name\":\"${DOMAIN}\",\"content\":\"${TOKEN_VALUE}\",\"ttl\":${SYS_TTL}}"
}

clean_challenge() {
    local DOMAIN="${1}" TOKEN_FILENAME="${2}" TOKEN_VALUE="${3}" ZONE ZONE_ID

    # This hook is called after attempting to validate each domain,
    # whether or not validation was successful. Here you can delete
    # files or DNS records that are no longer needed.
    #
    # The parameters are the same as for deploy_challenge.

    if ! ZONE=$(find_zone_by_fqdn "${DOMAIN}");
    then
        >&2 echo "Unable to find zone apex"
    fi

    if ! ZONE_ID=$(find_zone_id "${ZONE}");
    then
        >&2 echo "Unable to find zone id"
    fi

    clean_txt_record "${ZONE_ID}" "${DOMAIN}" "${TOKEN_VALUE}"
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


find_zone_by_fqdn() {
    local DOMAIN="${1}"

    while [[ -n "${DOMAIN}" ]]; do
        if [[ $(dig "${DOMAIN}" cname +short) ]];
        then
            DOMAIN="${DOMAIN#*.}"
            continue
        fi

        if [[ $(dig "${DOMAIN}" soa +short) ]];
        then
            echo "${DOMAIN}"
            return
        fi

        DOMAIN="${DOMAIN#*.}"
    done

    return 1
}

find_zone_id() {
    local ZONE="${1}" API_RESPONSE

    if ! API_RESPONSE=$(curl -s -f "${CF_API}/zones?name=${ZONE}" -H "Content-Type: application/json" -H "Authorization: Bearer ${SYS_API_TOKEN}");
    then
        return 1
    fi

    echo "${API_RESPONSE}" | jq --raw-output --exit-status ".result[0].id"
}

clean_txt_record() {
    local ZONE_ID="${1}" DOMAIN="${2}" CHALLENGE="${3}" API_RESPONSE RECORD_ID

    if ! API_RESPONSE=$(curl -s -f "${CF_API}/zones/${ZONE_ID}/dns_records?per_page=100&type=TXT&name=${DOMAIN}" -H "Content-Type: application/json" -H "Authorization: Bearer ${SYS_API_TOKEN}");
    then
        return 1
    fi

    if ! RECORD_ID=$(echo "${API_RESPONSE}" | jq --raw-output --exit-status ".result[] | select(.content | . == \"${CHALLENGE}\") | .id");
    then
        return
    fi

    curl -s -f -X DELETE "${CF_API}/zones/${ZONE_ID}/dns_records/${RECORD_ID}" -H "Content-Type: application/json" -H "Authorization: Bearer ${SYS_API_TOKEN}" > /dev/null
}