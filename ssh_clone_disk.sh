#!/bin/bash
# Clone a disk on the rig

source rsync_scripts.sh
ssh -t $SSH_USER \~/bin/automine/common/clone_disk.sh "$@"
