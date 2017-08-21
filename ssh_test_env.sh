#!/bin/bash

source ssh_ensure_env.sh
echo "Rig Environment: RIG_IP=${RIG_IP} RIG_USER=${RIG_USER} RIG_TYPE=${RIG_TYPE}"
echo "Ethminer Environment: WORKER=${WORKER} WALLET=${WALLET}"
echo "Build flags: ETHASHCUDA=${ETHASHCUDA}"
echo "Remote access? USE_PUBLIC=${USE_PUBLIC}"
echo "SSH_USER=${SSH_USER} SSH_PORT=${SSH_PORT}"