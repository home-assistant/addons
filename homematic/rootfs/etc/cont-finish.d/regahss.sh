#!/usr/bin/with-contenv bashio
# ==============================================================================
# Store RegaHss data
# ==============================================================================

echo "load tclrega.so; rega system.Save()" | "${HM_HOME}/bin/tclsh" 2> /dev/null || true
