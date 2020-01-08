#!/usr/bin/env bashio

STT=$(bashio::config 'stt')
TTS=$(bashio::config 'tts')

exec python3 -m ada --url "http://hassio/homeassistant/api" --key "$HASSIO_TOKEN" --stt "$STT" --tts "$TTS"
