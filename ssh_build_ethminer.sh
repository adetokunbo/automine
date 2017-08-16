#!/bin/bash
# Build the version of the ethminer for $RIG_TYPE on the rig.

source rsync_scripts.sh
ssh -t $SSH_USER -p${SSH_PORT} RIG_TYPE=${RIG_TYPE} ETHASHCUDA=${ETHASHCUDA} \~/bin/automine/common/build_ethminer.sh
