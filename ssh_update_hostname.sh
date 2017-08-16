#!/bin/bash
# Updates the hostname of the rig

source rsync_scripts.sh
ssh -t $SSH_USER -p${SSH_PORT} \~/bin/automine/common/update_hostname.sh "$@"
