#!/bin/bash

source rsync_scripts.sh
ssh -t $SSH_USER -p${SSH_PORT} RIG_TYPE=${RIG_TYPE} \~/bin/automine/common/systemd/install_systemd_units.sh
