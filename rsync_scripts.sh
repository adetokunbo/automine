#!/bin/bash

source ssh_ensure_env.sh
ssh ${SSH_USER} mkdir -p \~/bin
cp cfg/$RIG_IP.sh cfg.sh
rsync -avz --del --exclude=cfg/* . ${SSH_USER}:~/bin/automine
