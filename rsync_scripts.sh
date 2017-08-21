#!/bin/bash

source ssh_ensure_env.sh
ssh ${SSH_USER} -p${SSH_PORT} mkdir -p \~/bin
cp cfg/$RIG_IP.sh cfg.sh
[ -f cfg/$RIG_IP.overclock.json ] && cp cfg/$RIG_IP.overclock.json overclock.json
rsync -avz -e "ssh -p ${SSH_PORT}" --del --exclude=cfg/* . ${SSH_USER}:~/bin/automine

# Add a symlink to the logging config
ssh ${SSH_USER} -p${SSH_PORT} ln -sf \~/bin/automine/logging_config.json \~/.automine/var/logs



