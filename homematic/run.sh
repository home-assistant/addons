#!/bin/bash
set -e

$HM_HOME/bin/rfd -d -l 0 -f /opt/hm/etc/config/rfd.conf 
$HM_HOME/bin/ReGaHss -l 0 -f /opt/hm/etc/rega.conf
