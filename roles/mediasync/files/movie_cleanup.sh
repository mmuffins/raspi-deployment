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
		local_movie="$local_movies_dir/$moviefolder"
		if [ ! -d "$local_movie" ]; then
		echo "$d was not found in $local_movies_dir, moving to $bin_movies_dir"
			mv "$d" $bin_movies_dir/
			echo $(date) > "$bin_movies_dir/$moviefolder/deleteddate"
			continue
		fi

	# Remove individual files in the remote directory that are not also in the source directory
	rsync -ah --info=name --delete --bwlimit=$rsync_max_speed "$local_movie/" "$d/"
	fi
done