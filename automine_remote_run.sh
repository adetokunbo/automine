#!/bin/bash
# Run an automine remote command on a rig

source rsync_scripts.sh
set -u
ssh -t $SSH_USER -p${SSH_PORT} \~/bin/automine_run "$@"
