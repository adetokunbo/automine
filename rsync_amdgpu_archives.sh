#!/bin/bash

source ssh_ensure_env.sh
rsync -avz -e "ssh -p ${SSH_PORT}" --del $DOWNLOAD_DIR ${SSH_USER}:~/var/downloads
