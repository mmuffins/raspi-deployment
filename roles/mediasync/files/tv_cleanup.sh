#!/bin/bash

source ./variables

if mount | grep //brownie.lan/Maxtor/NVIDIA_SHIELD > /dev/null; then
    echo "${smb_share} is already mounted at ${local_mountpoint}"
else
    echo "mounting ${smb_share} to ${local_mountpoint}"
	mkdir $local_mountpoint
	sudo mount -t cifs $smb_share $local_mountpoint -o iocharset=utf8,username=$smb_username,password=$smb_password
fi

echo "cleaning up ${local_tv_dir}"

# go through each folder in the remote share recycle bin
find "$bin_tv_dir" -type f | while read file_path; do
  # Make sure all files in the recycle bin are also removed in the local directory
  relative_path=$(echo "$file_path" | sed "s|^$bin_tv_dir/||")
  delete_file="$local_tv_dir/$relative_path"
  echo "checking file: $delete_file"

  if [ -f "$delete_file" ]; then
    echo "removing ${relative_path}"
	rm -v "$delete_file"
  fi
  
  season_folder=$(dirname "$delete_file")
  if [ -z "$(ls -A "$season_folder")" ]; then
    echo "${season_folder} is empty, removing directory"
	rmdir -v "$season_folder"
  else
    echo "${season_folder} is not empty, keeping directory"
  fi

  show_folder=$(dirname "$season_folder")
  if [ -z "$(ls -A "$show_folder")" ]; then
    echo "${show_folder} is empty, removing directory"
	rmdir -v "$show_folder"
  else
    echo "${show_folder} is not empty, keeping directory"
  fi
done
