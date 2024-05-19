#!/bin/bash
source ./variables

if mount | grep "$smb_share" > /dev/null; then
  remote="/mnt/remotes/brownie"
  # Run multiple times to kill strugglers
  for i in {1..3}
  do
    rsync_processes=$(ps aux | grep -i "rsync" | grep "$remote")
    if [ -z "$rsync_processes" ]; then
      echo "No rsync processes found copying to $remote (Attempt $i), unmounting share"
      umount "$remote"
      exit 0
    else
      echo "$rsync_processes" | awk '{print $2}' | xargs -r kill
      echo "Killed all rsync processes copying to $remote (Attempt $i)"
    fi

    if [ $i -lt 3 ]; then
      sleep 30
    fi
  done

  echo "Final attempt to unmount $remote"
  umount "$remote"
fi


