#!/bin/bash
# Build the version of the ethminer for $RIG_TYPE on the rig.

source rsync_scripts.sh
ssh -t $SSH_USER \~/bin/automine/$RIG_TYPE/build_ethminer.sh
