#!/bin/bash

VERSION=0.3

echo "-------------------------------------------------------------------"
echo " "
echo "       marthoc/deconz Conbee/RaspBee Firmware Flashing Script"
echo " "
echo "                       Version: $VERSION"
echo " "
echo "-------------------------------------------------------------------"
echo " "
read -p "Enter C for Conbee, R for RaspBee, or press Enter now to exit: " device

if [ "$device" = "C" ] || [ "$device" = "c" ]; then
        echo " "
        echo "Listing attached devices..."
        echo " "

        /usr/bin/GCFFlasher_internal -l

        echo " "
        echo "Enter the Conbee device number, or press Enter now to exit."
        echo " "
        read -p "Device Number : " deviceNum

        if [[ -z "${deviceNum// }" ]]; then
                echo "Exiting..."
                exit 1
        fi
elif [[ -z "${device// }" ]]; then
        echo "Exiting..."
        exit 1
fi

echo " "
echo "-------------------------------------------------------------------"
echo " "
echo "Firmware available for flashing:"
echo " "

ls -1 /usr/share/deCONZ/firmware
#curl -s https://www.dresden-elektronik.de/rpi/deconz-firmware/ | grep deCONZ_Rpi_ | cut -d \> -f 7 | sed "s/...$//g" | grep -v .md5 | sort

echo " "
echo "Enter the firmware file name from above, including extension,"
echo "or press Enter now to exit."
echo " "

read -p "File Name : " fileName
echo " "
if [[ -z "${fileName// }" ]]; then
        echo "Exiting..."
        exit 1
        fi

#echo " "
#echo "Downloading firmware file and MD5 signature..."
#echo " "
#echo "------------------------------------------------------------"

#wget -O /$fileName http://dresden-elektronik.de/rpi/deconz-firmware/$fileName
#wget -O /$fileName.md5 http://dresden-elektronik.de/rpi/deconz-firmware/$fileName.md5

#echo "------------------------------------------------------------"
#echo " "
#echo "Comparing firmware file with MD5 signature..."
#echo " "

#cd /
#md5sum -c $fileName.md5
#retVal=$?

#if [ $retVal != 0 ]; then
#        echo " "
#        echo "MD5 mismatch! Exiting..."
#        echo " "
#        exit 1
#else
#        echo " "
#        echo "MD5 match!"
#        echo " "
#fi

echo "-------------------------------------------------------------------"
echo " "

if [ "$device" = "R" ] || [ "$device" = "r" ]; then
        echo "Device: RaspBee"
else 
        echo "Conbee Device Number: $deviceNum"
fi

echo " "
echo "Firmware File: $fileName"
echo " "
echo "Are the above device and firmware values correct?"
read -p "Enter Y to proceed, any other entry to exit: " correctVal

if [ "$correctVal" = "Y" ] || [ "$correctVal" = "y" ]; then
        echo " "
        echo "Flashing..."
        echo " "
        if [ "$device" = "C" ] || [ "$device" = "c" ]; then
        /usr/bin/GCFFlasher_internal -d $deviceNum -f /usr/share/deCONZ/firmware/$fileName
        elif [ "$device" = "R" ] || [ "$device" = "r" ]; then
        /usr/bin/GCFFlasher_internal -f /usr/share/deCONZ/firmware/$fileName
        fi
        
        retVal=$?
        if [ $retVal != 0 ]; then
                echo " "
                echo "Flashing Error! Please re-run this script..."
                echo " "
                exit $retVal
        fi
else
        echo " "
        echo "Exiting..."
        echo " "
        exit 1
fi
