#!/bin/bash

source ssh_ensure_env.sh
ssh ${SSH_USER} mkdir -p \~/bin
cp cfg/$RIG_IP.sh cfg.sh
[ -f cfg/$RIG_IP.overclock.json ] && cp cfg/$RIG_IP.overclock.json overclock.json
rsync -avz --del --exclude=cfg/* . ${SSH_USER}:~/bin/automine
