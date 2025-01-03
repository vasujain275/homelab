#!/bin/bash

# Automatically find the first available /dev/sdX device
DEVICE=$(ls /dev/sd* | grep -E '/dev/sd[a-z]' | head -n 1)

if [ -z "$DEVICE" ]; then
    echo "No valid /dev/sdX device found"
    exit 1
fi

# Mount the found device
mount $DEVICE /home/pi/hdd -o rw,uid=1000,gid=1000
