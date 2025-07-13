#!/bin/bash
# echo "Starting tv cleanup"
# ./tv_cleanup.sh

echo -e "\nStarting tv sync"
./tv_sync.sh

# echo -e "\nStarting movie cleanup"
# ./movie_cleanup.sh

echo -e "\nStarting movie sync"
./movie_sync.sh

echo -e "\nUnmounting share"
./unmount_share.sh