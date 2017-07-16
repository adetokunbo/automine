#!/bin/bash

source rsync_scripts.sh
ssh -t $SSH_USER \~/bin/automine/common/install_systemd_units.sh
