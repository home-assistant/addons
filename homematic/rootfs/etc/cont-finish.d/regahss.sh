#!/usr/bin/with-contenv bashio
# ==============================================================================
# Store RegaHss data
# ==============================================================================

echo "load tclrega.so; rega system.Save()" | "/opt/hm/bin/tclsh" 2> /dev/null || true
