#!/bin/bash
# Rebuild the kernel image on the rig.

source rsync_scripts.sh
ssh -t $SSH_USER \~/bin/automine/common/optimize_os_services.sh
