#!/bin/bash
source ./variables

if ! (mount | grep grep $smb_share > /dev/null); then
	echo "Mounting $smb_share to $local_mountpoint"
	mkdir -p $local_mountpoint
	sudo mount -t cifs $smb_share $local_mountpoint -o vers=3.0,iocharset=utf8,username=$smb_username,password=$smb_password
fi

if ! (mount | grep $smb_share > /dev/null); then
  echo "Could not mount $smb_share, aborting script"
  # Exit with 0 to indicate success to not prevent running other scripts
  exit 0
fi

echo "Syncing ${local_movies_dir} to ${remote_movies_dir}"
rsync -ah --info=name --bwlimit=$rsync_max_speed $local_movies_dir/ $remote_movies_dir/