#!/bin/bash
echo "Starting tv cleanup"
./tv_cleanup.sh

echo "Starting tv sync"
./tv_sync.sh

echo "Starting movie cleanup"
./movie_cleanup.sh

echo "Starting movie sync"
./movie_sync.sh

echo "Unmounting share"
./unmount_share.sh