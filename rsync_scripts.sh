#!/bin/bash

source ssh_ensure_env.sh
ssh ${SSH_USER} -p${SSH_PORT} mkdir -p \~/bin
cp cfg/$RIG_HOST.sh cfg.sh
[ -f cfg/$RIG_HOST.overclock.json ] && cp cfg/$RIG_HOST.overclock.json overclock.json
rsync -avz -e "ssh -p ${SSH_PORT}" --del --exclude=cfg/* . ${SSH_USER}:~/bin/automine
rm cfg.sh overclock.json

# Add a symlink to the logging config
ssh ${SSH_USER} -p${SSH_PORT} ln -sf \~/bin/automine/logging_config.json \~/.automine/var/logs



