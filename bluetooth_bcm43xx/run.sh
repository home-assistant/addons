#!/bin/bash
set -e

hciattach -n /dev/ttyAMA0 bcm43xx 115200 noflow - &
HCI_PID=$!

hciconfig hci0 up

wait $HCI_PID
