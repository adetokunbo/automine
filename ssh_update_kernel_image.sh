#!/bin/bash
# Rebuild the kernel image on the rig.

source rsync_scripts.sh

# set -u: fail if any specified environment variables are not set
set -u 
ssh -t $SSH_USER TARGET_KERNEL=${TARGET_KERNEL} \~/bin/automine/common/update_kernel_image.sh
set +u
