#!/bin/bash
# Upgrades the system, installing the latest security patches, etc

source rsync_scripts.sh
ssh -t $SSH_USER -p${SSH_PORT} \~/bin/automine/common/upgrade_system.sh "$@"
