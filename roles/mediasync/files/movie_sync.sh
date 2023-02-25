#!/bin/bash

source ./variables

if mount | grep //brownie.lan/Maxtor/NVIDIA_SHIELD > /dev/null; then
    echo "${smb_share} is already mounted at ${local_mountpoint}"
else
    echo "mounting ${smb_share} to ${local_mountpoint}"
	mkdir $local_mountpoint
	sudo mount -t cifs $smb_share $local_mountpoint -o iocharset=utf8,username=$smb_username,password=$smb_password
fi

echo "syncing ${local_movies_dir} to ${remote_movies_dir}"
rsync -avh $local_movies_dir/ $remote_movies_dir/