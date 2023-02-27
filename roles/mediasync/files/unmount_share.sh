#!/bin/bash
source ./variables

if mount | grep "$smb_share" > /dev/null; then
	umount /mnt/remotes/brownie
fi