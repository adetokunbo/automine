#!/bin/bash

if [ -z ${RIG_IP+x} ]; then
	echo "RIG_IP is unset. Do the following filling in your rig's IP"
	echo "export RIG_IP=FILL_THIS_IN"
	exit
fi
if [ ! -f cfg/${RIG_IP}.sh ]; then
	echo "File not found: cfg/${RIG_IP}.sh"
	echo "Do the following to create the file:"
	echo "cp cfg/127.0.0.1.sample.sh cfg/${RIG_IP}.sh"
	echo "Then edit the file and fill in the relevant values for your rig."
	echo "After filling in the vaules, run this script again."
	exit
fi
source cfg/${RIG_IP}.sh
if [ "$USE_PUBLIC" = true ]; then
	SSH_USER="${RIG_USER}@${PUBLIC_HOSTNAME}"
else
	SSH_USER=${RIG_USER}@${RIG_IP}
fi
DOWNLOAD_DIR=${HOME}/Downloads/${RIG_TYPE}
[ ${RIG_TYPE} == 'nvidia' ] && ETHASHCUDA=ON || ETHASHCUDA=OFF
