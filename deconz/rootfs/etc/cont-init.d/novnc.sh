#!/usr/bin/with-contenv bashio
# ==============================================================================
# Setup noVNC
# ==============================================================================
declare ingress_entry
ingress_entry=$(bashio::addon.ingress_entry)
sed -i "s#websockify#${ingress_entry#?}/novnc/websockify#g" /usr/share/novnc/vnc_lite.html
