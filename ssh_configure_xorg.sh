#!/bin/bash
# Creates an edid.bin used on Nvidia rigs.

source rsync_scripts.sh
ssh -t $SSH_USER \~/bin/automine/nvidia/configure_xorg.sh

