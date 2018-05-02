#!/bin/sh

#set -x
API_KEY=$HASSIO_TOKEN
PLATFORM=$1
FILE=$2
LANG=$3
TEXT=$4

MESSAGE="\"{\"message\": \"$TEXT\", \"platform\": \"$PLATFORM\"}\""
echo $MESSAGE

RESPONSE=$(eval curl -s -H \"x-ha-access: $API_KEY\" -H \"Type: application/json\" http://hassio/homeassistant/api/tts_get_url -d $MESSAGE)
if [ "$RESPONSE" = "" ]; then
    exit 1
fi
echo $RESPONSE

URL=`echo $RESPONSE | jq --raw-output '.url'`
if [ "$URL" = "" ]; then
    exit 1
fi

rm /tmp/temp.mp3
curl -s -H "x-ha-access: $API_KEY" "$URL" -o /tmp/temp.mp3
if [ -f /tmp/temp.mp3 ]; then
  /usr/bin/mpg123 -w $FILE /tmp/temp.mp3
fi
rm /tmp/temp.mp3

