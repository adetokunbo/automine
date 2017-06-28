#!/bin/bash
# Update bashrc to include useful commands and show the screen on login

source rsync_scripts.sh
ssh $SSH_USER \~/bin/automine/common/update_bashrc.sh
