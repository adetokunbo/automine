#!/bin/bash
# Rebuild the kernel image on the rig.

source rsync_scripts.sh
ssh -t $SSH_USER -p${SSH_PORT} \~/bin/automine/common/optimize_os_services.sh
