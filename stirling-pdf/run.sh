#!/usr/bin/env sh
set -e

OPTIONS=/data/options.json

# Create the persistent targets before Stirling starts writing
mkdir -p /data/configs /data/logs /data/customFiles /data/pipeline

get() { jq -r --arg k "$1" '.[$k] // empty' "$OPTIONS"; }

ENABLE_LOGIN="$(get enable_login)"
APP_NAME="$(get app_name)"
DEFAULT_LOCALE="$(get default_locale)"
LANGUAGES="$(get languages)"
UPLOAD_LIMIT="$(get file_upload_limit)"
INIT_USER="$(get initial_username)"
INIT_PASS="$(get initial_password)"

export SECURITY_ENABLELOGIN="${ENABLE_LOGIN:-false}"
[ -n "$APP_NAME" ]       && export UI_APPNAME="$APP_NAME" UI_APPNAMENAVBAR="$APP_NAME"
[ -n "$DEFAULT_LOCALE" ] && export SYSTEM_DEFAULTLOCALE="$DEFAULT_LOCALE"
[ -n "$LANGUAGES" ]      && export LANGS="$LANGUAGES"
[ -n "$UPLOAD_LIMIT" ]   && export SYSTEMFILEUPLOADLIMIT="$UPLOAD_LIMIT"
[ -n "$INIT_USER" ]      && export SECURITY_INITIALLOGIN_USERNAME="$INIT_USER"
[ -n "$INIT_PASS" ]      && export SECURITY_INITIALLOGIN_PASSWORD="$INIT_PASS"

echo "[hivebit] Starting Stirling-PDF (login=${SECURITY_ENABLELOGIN})"

# Hand off to Stirling's own init/launch script.
# VERIFY this matches the image's real entrypoint (see step 3).
exec /scripts/init.sh