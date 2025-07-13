#!/bin/bash
source ./variables

if ! (mount | grep "$smb_share" > /dev/null); then
  echo "Mounting $smb_share to $local_mountpoint"
  mkdir -p $local_mountpoint
  sudo mount -t cifs $smb_share $local_mountpoint -o vers=3.0,iocharset=utf8,username=$smb_username,password=$smb_password
fi

if ! (mount | grep "$smb_share" > /dev/null); then
  echo "Could not mount $smb_share, aborting script"
  # Exit with 0 to indicate success to not prevent running other scripts
  exit 0
fi

echo "Syncing ${local_tv_dir} to ${remote_tv_dir}"
rsync -ah --info=name --delete --bwlimit=$rsync_max_speed $local_tv_dir/ $remote_tv_dir/

# # ensure each show in the local folder also exists on the remote share
# for d in $local_tv_dir/*/ ; do
#   tvfolder=$(basename "$d")
#   if [ ! -d "$remote_tv_dir/$tvfolder" ]; then
# 	echo "Creating folder $tvfolder in $remote_tv_dir"
# 	mkdir "$remote_tv_dir/$tvfolder"
#   fi
  
#   # copy the current season (which hopefully has the lowest name) for each show to the remote share
#   cd "$d"
#   lowestSeason=$(ls -vdF Season*/ | head -n1)
#   remoteSeasonFolder="$remote_tv_dir/$tvfolder/$lowestSeason"
#   if [ ! -d "$remoteSeasonFolder" ]; then
# 	echo "Creating folder ${lowestSeason} in ${remote_tv_dir}/${tvfolder}"
# 	mkdir "$remoteSeasonFolder"
#   fi
    
#   rsync -ah --info=name --bwlimit=$rsync_max_speed "$d/$lowestSeason" "$remoteSeasonFolder/"
# done