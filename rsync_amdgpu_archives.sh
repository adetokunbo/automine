#!/bin/bash

source ssh_ensure_env.sh
rsync -avz --del $DOWNLOAD_DIR ${SSH_USER}:~/var/downloads
