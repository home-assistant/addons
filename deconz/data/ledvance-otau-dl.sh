#!/bin/bash

URL_OSRAM="https://api.update.ledvance.com/v1/zigbee/firmwares"

while true
do

    # fetch data
    if ! OSRAM_DATA="$(curl -sL ${URL_OSRAM})"; then
        echo "[Info] Can't fetch data from osram!"
        sleep 18000
        continue
    fi

    OSRAM_DATA_SIZE="$(echo "${OSRAM_DATA}" | jq --raw-output '.firmwares | length')"
    DL_DONE=0
    for (( i=0; i < "${OSRAM_DATA_SIZE}"; i++ )); do
        OSRAM_COMPANY=$( echo "${OSRAM_DATA}" | jq --raw-output ".firmwares[$i].identity.company  // empty" 2>/dev/null)
        OSRAM_PRODUCT=$( echo "${OSRAM_DATA}" | jq --raw-output ".firmwares[$i].identity.product  // empty" 2>/dev/null)
        OTAU_FILENAME=$( echo "${OSRAM_DATA}" | jq --raw-output ".firmwares[$i].name  // empty" 2>/dev/null)
        OTAU_URL="$URL_OSRAM/download/${OSRAM_COMPANY}/${OSRAM_PRODUCT}/latest"
				
        if [ -z "${OTAU_URL}" ]; then
            continue
        fi
				
				
        OTAU_FILE="/data/otau/${OTAU_FILENAME}"
        if [ -f "${OTAU_FILE}" ] &&  [[ $(file --mime-type -b "${OTAU_FILE}") == "application/octet-stream" ]]  ; then
            continue
        fi
        curl -s -L -o "${OTAU_FILE}" "${OTAU_URL}"
        ((DL_DONE++))
        if [ "$((DL_DONE % 10))" == "0" ]; then
          # LEDVANCE/OSRAM API RateLimits : The rate limit 10 calls per 60 seconds or quota 100 MB per month.
          DL_DONE=0
        	sleep 65
        fi
    done

    sleep 259200
done
