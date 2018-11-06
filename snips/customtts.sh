#!/bin/bash

#set -x
API_KEY="$HASSIO_TOKEN"
PLATFORM="$1"
FILE="$2"
LANG="$3"
TEXT="$4"

MESSAGE="\"{\\\"message\\\": \\\"${TEXT}\\\", \\\"platform\\\": \\\"${PLATFORM}\\\"}\""
echo "${MESSAGE}"

RESPONSE=$(eval curl -s  -d "${MESSAGE}" -H \"Authorization: Bearer "${API_KEY}"\" -H \"Type: application/json\" http://hassio/homeassistant/api/tts_get_url)
if [ -z "${RESPONSE}" ]; then
    exit 1
fi
echo "${RESPONSE}"

URL="$(echo "${RESPONSE}" | jq --raw-output '.url')"
if [ -z "${URL}" ]; then
    exit 1
fi

rm -f /tmpfs/temp.mp3
curl -s -H "Authorization: Bearer ${API_KEY}" "${URL}" -o /tmpfs/temp.mp3
if [ -f /tmpfs/temp.mp3 ]; then
  /usr/bin/mpg123 -w "${FILE}" /tmpfs/temp.mp3
fi
rm -f /tmpfs/temp.mp3
