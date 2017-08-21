#!/bin/bash
# Clone a disk on the rig

source rsync_scripts.sh
ssh -t $SSH_USER -p${SSH_PORT} \~/bin/automine/common/clone_disk.sh "$@"
