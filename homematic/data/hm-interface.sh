#!/bin/bash


function enable_interface(){
    local $name=$1

    sed -i "/<!--$name/d" /etc/config/InterfacesList.xml
    sed -i "/$name-->/d" /etc/config/InterfacesList.xml
}


function init_interface_list() {
    local $rf=$1
    local $ip=$2
    local $wired=$3

    if [ "$rf" == "true" ]; then
        enable_interface "rf"
    fi

    if [ "$ip" == "true" ]; then
        enable_interface "ip"
    fi

    if [ "$wired" == "true" ]; then
        enable_interface "wired"
    fi
}