#!/bin/bash
set -e

SERIAL="$(grep Serial /proc/cpuinfo | cut -c19-)"
B1="$(echo "$SERIAL" | cut -c3-4)"
B2="$(echo "$SERIAL" | cut -c5-6)"
B3="$(echo "$SERIAL" | cut -c7-8)"
BDADDR="$(printf b8:27:eb:%02x:%02x:%02x $((0x$B1 ^ 0xaa)) $((0x$B2 ^ 0xaa)) $((0x$B3 ^ 0xaa)))"

hciattach /dev/ttyAMA0 bcm43xx 921600 noflow - "$BDADDR"
hciconfig hci0 up

while pgrep hciattach > /dev/null
do
    sleep 600
done
