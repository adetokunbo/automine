#!/bin/bash
# Rebuild the kernel image on the rig.

source rsync_scripts.sh
ssh -t $SSH_USER \~/bin/automine/common/use_eth0_as_interface.sh
