#!/usr/bin/with-contenv bashio
# ==============================================================================
# Initialize file system layout /data
# ==============================================================================

mkdir -p /share/hm-firmware
mkdir -p /share/hmip-firmware
mkdir -p /data/crRFD
mkdir -p /data/rfd
mkdir -p /data/hs485d
mkdir -p /data/userprofiles

# Init files
touch /data/groups.json
touch /data/hmip_user.conf
touch /data/rega_user.conf
touch /data/homematic.regadom
touch /data/userprofiles/userAckInstallWizard_Admin

# Persist
ln -s /data/userprofiles /etc/config/userprofiles
ln -s /data/groups.gson /etc/config/groups.gson
