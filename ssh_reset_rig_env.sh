#!/bin/bash
# Updates a rig so all automine tasks use a simply local directory hierarchy

set -e

source ssh_ensure_rig_env.sh
source rsync_scripts.sh
ssh ${SSH_USER} -p${SSH_PORT} \~/bin/automine/common/reset_rig_env.sh
ssh -t ${SSH_USER} -p${SSH_PORT} RIG_TYPE=${RIG_TYPE} \~/bin/automine/common/systemd/install_systemd_units.sh
ssh ${SSH_USER} -p${SSH_PORT} systemctl --user start automine



