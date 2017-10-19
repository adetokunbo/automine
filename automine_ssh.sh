#!/bin/bash
# Open an ssh session on a rig

source automine_sync_rig.sh
set -u
ssh $SSH_USER -p${SSH_PORT} "$@"
