#!/bin/bash

source ./variables

if mount | grep //brownie.lan/Maxtor/NVIDIA_SHIELD > /dev/null; then
    echo "Unmounting ${local_mountpoint}"
	umount /mnt/remotes/brownie
fi