#!/bin/bash
set -e

# Hook for automatic DNS-01 challenge deployment on Cloudflare
/opt/letsencrypt-cloudflare-hook/hook.py "$@"

# Haas.io Specific Deployment
case "$1" in
    "deploy_cert")
        cp -f "$5" "/ssl/$CERTFILE"
        cp -f "$3" "/ssl/$KEYFILE"
        ;;
esac
