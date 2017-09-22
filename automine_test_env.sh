#!/bin/bash

this_dir=$(dirname "${BASH_SOURCE[${#BASH_SOURCE[@]} - 1]}")
source _automine_ensure_env.sh
echo "Rig Environment: RIG_HOST=${RIG_HOST} RIG_USER=${RIG_USER} RIG_TYPE=${RIG_TYPE}"
echo "Ethminer options: $(${this_dir}/show_config.py ethminer_opts)"
echo "Ethminer environment: $(${this_dir}/show_config.py ethminer_exports)"
echo "Build flags: ETHASHCUDA=${ETHASHCUDA}"
echo "Remote access? USE_PUBLIC=${USE_PUBLIC}"
echo "SSH_USER=${SSH_USER} SSH_PORT=${SSH_PORT}"
