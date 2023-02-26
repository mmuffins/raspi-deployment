#!/bin/bash
echo "starting tv cleanup"
./tv_cleanup.sh

echo "starting tv sync"
./tv_sync.sh

echo "starting movie cleanup"
./movie_cleanup.sh

echo "starting movie sync"
./movie_sync.sh

echo "unmounting share"
./unmount_share.sh