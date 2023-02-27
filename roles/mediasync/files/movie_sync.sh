#!/bin/bash
source ./variables

if ! (mount | grep //brownie.lan/Maxtor/NVIDIA_SHIELD > /dev/null); then
	echo "Mounting $smb_share to $local_mountpoint"
	mkdir $local_mountpoint
	sudo mount -t cifs $smb_share $local_mountpoint -o vers=3.0,iocharset=utf8,username=$smb_username,password=$smb_password
fi

echo "Syncing ${local_movies_dir} to ${remote_movies_dir}"
rsync -avh --bwlimit=$rsync_max_speed $local_movies_dir/ $remote_movies_dir/