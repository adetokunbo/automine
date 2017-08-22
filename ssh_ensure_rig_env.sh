#!/bin/bash
# Ensure that rig has the expected user directories

source ssh_ensure_env.sh
set -u  # fail if a referenced ENV variable is not set

ssh ${SSH_USER} -p${SSH_PORT} mkdir -v -m 777 -p \~/.automine/var/logs
ssh ${SSH_USER} -p${SSH_PORT} mkdir -v -m 777 -p \~/.automine/var/triggers
ssh ${SSH_USER} -p${SSH_PORT} mkdir -v -m 755 -p \~/.automine/var/src
ssh ${SSH_USER} -p${SSH_PORT} mkdir -v -m 755 -p \~/.automine/lib/install


