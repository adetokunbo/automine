#!/bin/bash
# Creates an edid.bin used on Nvidia rigs.

source rsync_scripts.sh

# Use any argument (.e.g, yes,Y,foo) to attempt to generate the edid.bin.
#
# Without an argument, the default pre-configured edid.bin is used
ssh -t $SSH_USER -p${SSH_PORT} \~/bin/automine/nvidia/configure_xorg.sh "$@"

