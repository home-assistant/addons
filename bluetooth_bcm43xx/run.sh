#!/bin/bash
set -e

hciattach /dev/ttyAMA0 bcm43xx 115200 noflow -
hciconfig hci0 up

while pgrep hciattach > /dev/null
do
  sleep 600
done
