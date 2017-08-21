#!/bin/bash
# Install the appropriate driver for $RIG_TYPE of the rig.

source rsync_scripts.sh

# Necessary because the amd driver archives can't be obtained directly via wget,
# so need to be downloaded locally and copied across
[ -f rsync_${RIG_TYPE}_archives.sh ] && source rsync_${RIG_TYPE}_archives.sh

ssh -t $SSH_USER -p${SSH_PORT} CUDA_VERSION=${CUDA_VERSION} \~/bin/automine/${RIG_TYPE}/install_driver.sh
