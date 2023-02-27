#!/bin/bash
source ./variables

if ! (mount | grep //brownie.lan/Maxtor/NVIDIA_SHIELD > /dev/null); then
	echo "Mounting $smb_share to $local_mountpoint"
	mkdir $local_mountpoint
	sudo mount -t cifs $smb_share $local_mountpoint -o vers=3.0,iocharset=utf8,username=$smb_username,password=$smb_password
fi

for d in "$remote_movies_dir/"*/ ; do
	moviefolder=$(basename "$d")
	if [ -d "$d" ]; then
		if [ ! -d "$local_movies_dir/$moviefolder" ]; then
		echo "Moving $d to $bin_movies_dir"
			mv "$d" $bin_movies_dir/
			echo $(date) > "$bin_movies_dir/$moviefolder/deleteddate"
		fi
	fi
done