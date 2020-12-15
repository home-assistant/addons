#!/usr/bin/with-contenv bashio
# ==============================================================================
# Generate InterfacesList.xml
# ==============================================================================
declare rf
declare ip
declare wired
declare interface_xml

rf=$(bashio::config "rf_enable")
ip=$(bashio::config "hmip_enable")
wired=$(bashio::config "wired_enable")
interface_xml="/etc/config/InterfacesList.xml"

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
    ) >> ${interface_xml}
}


echo -e "<?xml version=\"1.0\" encoding=\"utf-8\" ?>\n<interfaces v=\"1.0\">" > ${interface_xml}
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

echo "</interfaces>" >> ${interface_xml}
