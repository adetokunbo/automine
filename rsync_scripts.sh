#!/bin/bash

source ssh_ensure_env.sh

# Ensure runtime directories are present
ssh ${SSH_USER} -p${SSH_PORT} mkdir -p \~/bin
ssh ${SSH_USER} -p${SSH_PORT} mkdir -v -m 777 -p \~/.automine/var/{logs,triggers}
ssh ${SSH_USER} -p${SSH_PORT} mkdir -v -m 755 -p \~/.automine/{var/src,lib/install}

# Sync the scripts and config
cp ${AUTOMINE_CFG_PATH} automine_config.json
rsync -avz -e "ssh -p ${SSH_PORT}" --del --exclude=cfg/* . ${SSH_USER}:~/bin/automine
rm automine_config.json

# Add the symlinks used in the commands
ssh ${SSH_USER} -p${SSH_PORT} ln -sf \~/bin/automine/logging_config.json \~/.automine/var/logs
ssh ${SSH_USER} -p${SSH_PORT} ln -sf \~/bin/automine/automine_config.json \~/.automine/
ssh ${SSH_USER} -p${SSH_PORT} ln -sf \~/bin/automine/show_config.py \~/bin/automine_show_config
ssh ${SSH_USER} -p${SSH_PORT} ln -sf \~/bin/automine/dispatch_command.sh \~/bin/automine_run

