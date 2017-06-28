#!/bin/bash
# Install vnc4server on the rig

source rsync_scripts.sh
ssh -t $SSH_USER \~/bin/automine/common/install_autologin_desktop.sh
