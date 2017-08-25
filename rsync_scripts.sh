#!/bin/bash

source ssh_ensure_env.sh
ssh ${SSH_USER} -p${SSH_PORT} mkdir -p \~/bin
cp cfg/${RIG_HOST}.automine_config.json automine_config.json
rsync -avz -e "ssh -p ${SSH_PORT}" --del --exclude=cfg/* . ${SSH_USER}:~/bin/automine
rm automine_config.json

# Add config symlinks
ssh ${SSH_USER} -p${SSH_PORT} ln -sf \~/bin/automine/logging_config.json \~/.automine/var/logs
ssh ${SSH_USER} -p${SSH_PORT} ln -sf \~/bin/automine/automine_config.json \~/.automine/
ssh ${SSH_USER} -p${SSH_PORT} ln -sf \~/bin/automine/show_config.py \~/bin/automine_show_config



