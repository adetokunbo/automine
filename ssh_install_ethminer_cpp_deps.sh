#!/bin/bash
# Install the dependencies needed to build the ethminer on the rig.

source rsync_scripts.sh
ssh -t $SSH_USER \~/bin/automine/common/install_ethminer_cpp_deps.sh
