#!/bin/bash


source ./variables

if mount | grep //brownie.lan/Maxtor/NVIDIA_SHIELD > /dev/null; then
    echo "${smb_share} is already mounted at ${local_mountpoint}"
else
    echo "mounting ${smb_share} to ${local_mountpoint}"
	mkdir $local_mountpoint
	sudo mount -t cifs $smb_share $local_mountpoint -o iocharset=utf8,username=$smb_username,password=$smb_password
fi

# Move folders not in local movies directory
for d in $remote_movies_dir/*/ ; do
  moviefolder=$(basename "$d")
  if [ ! -d "$local_movies_dir/$moviefolder" ]; then
	echo "moving ${d} to ${bin_movies_dir}"
    mv "$d" $bin_movies_dir/
    echo $(date) > $bin_movies_dir/$moviefolder/deleteddate
  fi
done