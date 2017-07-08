#!/bin/bash
# Updates the hostname of the rig

source rsync_scripts.sh
ssh -t $SSH_USER \~/bin/automine/common/update_hostname.sh "$@"
