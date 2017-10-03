#!/bin/bash
# Run an automine remote command on a rig

source automine_sync_rig.sh
set -u
ssh -t $SSH_USER -p${SSH_PORT} \~/bin/automine_run "$@"
