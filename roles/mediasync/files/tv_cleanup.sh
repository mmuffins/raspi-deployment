#!/bin/bash
source ./variables

if ! (mount | grep //brownie.lan/Maxtor/NVIDIA_SHIELD > /dev/null); then
  echo "Mounting ${smb_share} to ${local_mountpoint}"
	mkdir $local_mountpoint
	sudo mount -t cifs $smb_share $local_mountpoint -o vers=3.0,iocharset=utf8,username=$smb_username,password=$smb_password
fi

echo "Deleting watched episodes in ${local_tv_dir}"

# Make sure all files in the recycle bin are also removed in the local directory
find "$bin_tv_dir" -type f | while read file_path; do
  filename=$(basename "$file_path")
  show=$(echo "$filename" | cut -d'-' -f1 | xargs)
  season=$(echo "$filename" | sed -n 's/.*\- S\([0-9]*\)E.*/\1/p' | awk '{printf "%02d\n", $1}')
  relative_path="$show/Season $season/$filename"
  delete_file="$local_tv_dir/$relative_path"

  if [ -f "$delete_file" ]; then
    echo "Removing file ${relative_path}"
    if rm -v "$delete_file"; then
      rm -v "$file_path"
    fi
  else
    echo "Could not find file $delete_file, moving to $bin_tv_notfound_files_dir"
    mv -v "$file_path" "$bin_tv_notfound_files_dir"
    continue
  fi
  
  season_folder=$(dirname "$delete_file")
  if [ -z "$(ls -A "$season_folder")" ]; then
    echo "Season folder ${season_folder} is empty, removing directory"
    rmdir -v "$season_folder"
  else
    continue
  fi

  show_folder=$(dirname "$season_folder")
  if [ -z "$(ls -A "$show_folder")" ]; then
    echo "Show folder ${show_folder} is empty, removing directory"
    rmdir -v "$show_folder"
  fi
done

echo "Cleaning up empty recycle bin directories in $bin_tv_dir"
for d in "$bin_tv_dir/*/" ; do 
  if [ -d "$d" ]; then
    if [ -z "$(ls -A "$d")" ]; then
      echo "Removing empty directory $d"
      rmdir -v "$d"
    fi
  fi
done