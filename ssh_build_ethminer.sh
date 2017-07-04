#!/bin/bash
# Build the version of the ethminer for $RIG_TYPE on the rig.

source rsync_scripts.sh
[ ${RIG_TYPE}=='nvidia' ] && ETHASHCUDA=ON || ETHASHCUDA=OFF
ssh -t $SSH_USER RIG_TYPE=${RIG_TYPE} ETHASHCUDA=${ETHASHCUDA} \~/bin/automine/common/build_ethminer.sh
