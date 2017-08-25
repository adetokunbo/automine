#!/bin/bash

source ssh_ensure_env.sh
ssh ${SSH_USER} -p${SSH_PORT} mkdir -p \~/bin
cp cfg/${RIG_HOST}.overclock.json overclock.json
rsync -avz -e "ssh -p ${SSH_PORT}" --del --exclude=cfg/* . ${SSH_USER}:~/bin/automine
rm overclock.json

# Add config symlinks
ssh ${SSH_USER} -p${SSH_PORT} ln -sf \~/bin/automine/logging_config.json \~/.automine/var/logs
ssh ${SSH_USER} -p${SSH_PORT} ln -sf \~/bin/automine/overclock.json \~/.automine/rig_config.json
ssh ${SSH_USER} -p${SSH_PORT} ln -sf \~/bin/automine/show_config.py \~/bin/automine_show_config



