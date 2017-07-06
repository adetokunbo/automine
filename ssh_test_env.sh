#!/bin/bash

source ssh_ensure_env.sh
echo "Rig Environment: RIG_IP=${RIG_IP} RIG_USER=${RIG_USER} RIG_TYPE=${RIG_TYPE}"
echo "Ethminer Environment: WORKER=${WORKER} WALLET=${WALLET}"
echo "Build flags: ETHASHCUDA=${ETHASHCUDA}"
