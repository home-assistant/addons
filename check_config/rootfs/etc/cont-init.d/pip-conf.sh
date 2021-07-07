#!/usr/bin/with-contenv bashio
# ==============================================================================
# Set global pip configuration
# ==============================================================================

echo -e "[global]\n" \
  "find-links = ${WHEELS_LINKS}\n" \
  "disable-pip-version-check = True" > /etc/pip.conf