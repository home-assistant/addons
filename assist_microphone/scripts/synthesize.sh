#!/command/with-contenv bashio
# vim: ft=bash
# shellcheck shell=bash
# ==============================================================================

###
# This script is used to send text to a Home Assistant webhook.
#
# It is intended to be used within the context of a wyoming-satellite
# --synthesize-command when text-to-speech text is returned on stdin.
#
# Author: https://github.com/AlfredJKwack
###

set -e

# Take text on stdin and JSON-encode it
text="$(cat | jq -R -s '.')"

# Set the default webhook name if not set in the configuration
if bashio::var.has_value "$(bashio::config 'webhook_id')"; then
  webhook_id="$(bashio::config 'webhook_id')"
else
  bashio::log.warning  "webhook_id is not set. Will set to default"
  webhook_id="synthesize-assist-microphone-response"
fi

# Check if SUPERVISOR_TOKEN is set
if [ -z "$SUPERVISOR_TOKEN" ]; then
    bashio::log.error "SUPERVISOR_TOKEN is not set. Exiting."
    exit 1
fi

# Get the IPv4 address from the first Home Assistant interface
ha_ip=$(curl -s -X GET \
    -H "Authorization: Bearer $SUPERVISOR_TOKEN" \
    http://supervisor/network/info \
  | jq -r '.data.interfaces[0].ipv4.address[0]' \
  | cut -d'/' -f1)
if [ -z "$ha_ip" ]; then
  bashio::log.error "Failed to get Home Assistant IPv4 address."
  exit 1
fi

# Determine if the HA host has SSL enabled.
ssl_enabled=$(curl -s -X GET \
  -H "Authorization: Bearer $SUPERVISOR_TOKEN" \
  http://supervisor/homeassistant/info \
  | jq -r '.data.ssl')
if [ -z "$ssl_enabled" ]; then
  bashio::log.error "Failed to determine if SSL is enabled."
  exit 1
fi

# Construct webhook URL based on SSL state, IP and webhook
if [[ "$ssl_enabled" == "true" ]]; then
  webhookurl="https://${ha_ip}:8123/api/webhook/${webhook_id}"
else
  webhookurl="http://${ha_ip}:8123/api/webhook/${webhook_id}"
fi
bashio::log.info  "Webhookurl set to : $webhookurl"

# Send the text to the Home Assistant Webhook.
json_payload="{\"response\": ${text}}"
if bashio::config.true 'debug_logging'; then
    #only send when in debug to avoid leaking potentially sensitive things.
    bashio::log.info "Payload for webhook: ${json_payload}"
fi
response=$(curl -s -o /dev/null -w "%{http_code}" -k -X POST \
  -H "Content-Type: application/json" \
  -d "$json_payload" \
  "${webhookurl}")
if [ "$response" -ne 200 ]; then
  bashio::log.error "Failed to send text to webhook. HTTP status code: $response"
  exit 1
fi
bashio::log.info "Successfully sent text to webhook."