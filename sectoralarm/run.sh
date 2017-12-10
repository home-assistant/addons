#!/bin/bash
set -e

echo "[Info] Installation of custom component: Sector Alarm"
echo "[Info] Any existing installation will be overwritten/updated"

mkdir -p /usr/src
cd /usr/src

echo "[Info] Downloading latest hass-sectoralarm.."
git clone -b master --depth 1 https://github.com/mgejke/hass-sectoralarm
rm hass-sectoralarm/README.md

echo "[Info] Downloading latest asyncsector.."
git clone -b master --depth 1 https://github.com/mgejke/asyncsector 

mkdir -p config/custom_components
cp -fR /usr/src/hass-sectoralarm/* /config/custom_components
cp -fR /usr/src/asyncsector/asyncsector /config/custom_components
rm -Rf /usr/src

echo "[Info] Installation done!"
printf "[Info] Complete the setup of Sector Alarm by adding\nthe necessary information in your configuration.yaml\n"
printf "Credit to mgejke for creating hass-sectoralarm and asyncsector\n https://github.com/mgejke"
