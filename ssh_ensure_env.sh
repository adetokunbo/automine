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

# Fail with a useful warning if the deprecated value for $AUTOMINE_ALERT_DIR is set
if [ -n ${AUTOMINE_ALERT_DIR:=''} ] || [ -z ${AUTOMINE_RUNTIME_DIR} ]; 
then
    echo "AUTOMINE_ALERT_DIR is deprecated, instead: "
    echo "1) set \$AUTOMINE_RUNTIME_DIR to \$HOME/.automine/var"
    echo "2) run ./ssh_reset_rig_env.sh"
    exit
fi

if [ "${USE_PUBLIC:=false}" = true ]; then
	SSH_USER="${RIG_USER}@${PUBLIC_HOSTNAME}"
	SSH_PORT=${PUBLIC_SSH_PORT:=0}
	[ ${SSH_PORT}==0 ] && SSH_PORT=${LOCAL_SSH_PORT:=22}
else
	SSH_USER=${RIG_USER}@${RIG_IP}
	SSH_PORT=${LOCAL_SSH_PORT:=22}
fi
DOWNLOAD_DIR=${HOME}/Downloads/${RIG_TYPE}
[ ${RIG_TYPE} == 'nvidia' ] && ETHASHCUDA=ON || ETHASHCUDA=OFF

