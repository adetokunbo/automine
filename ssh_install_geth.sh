#!/bin/bash
# Installs geth as a background service on the rig.

source rsync_scripts.sh
ssh -t $SSH_USER \~/bin/automine/common/install_geth.sh
