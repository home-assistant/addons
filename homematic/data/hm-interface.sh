#!/usr/bin/env bashio


function enable_interface(){
    local name="$1"
    local description="$2"
    local port="$3"

    (
        echo "  <ipc>"
        echo "    <name>${name}</name>"
        echo "    <url>xmlrpc://127.0.0.1:${port}</url>"
        echo "    <info>${description}</info>"
        echo "  </ipc>"
    ) >> /etc/config/InterfacesList.xml
}


function init_interface_list() {
    local rf=$1
    local ip=$2
    local wired=$3

    echo -e "<?xml version=\"1.0\" encoding=\"utf-8\" ?>\n<interfaces v=\"1.0\">" > /etc/config/InterfacesList.xml
    enable_interface "VirtualDevices" "Virtual Devices" "9292/groups"

    if [ "$rf" == "true" ]; then
        enable_interface "BidCos-RF" "BidCos-RF" "2001"
    fi

    if [ "$ip" == "true" ]; then
        enable_interface "HmIP-RF" "HmIP-RF" "2010"
    fi

    if [ "$wired" == "true" ]; then
        enable_interface "Hm-Wired" "Hm-Wired" "2000"
    fi

    echo "</interfaces>" >> /etc/config/InterfacesList.xml
}