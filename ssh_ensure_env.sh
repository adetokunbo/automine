#!/bin/bash
set -e

if [ -z ${RIG_HOST+x} ]; then
	echo "RIG_HOST is unset. Do the following filling in your rig's hostname or ip address"
	echo "export RIG_HOST=FILL_THIS_IN"
	exit
fi
if [ ! -f cfg/${RIG_HOST}.automine_config.json ]; then
	echo "File not found: cfg/${RIG_HOST}.automine_config.json"
	echo "Do the following to create the file:"
	echo "cp cfg/127.0.0.1.automine_config.json cfg/${RIG_HOST}.automine_config.json"
	echo "Then edit the file and fill in the relevant values for your rig."
	echo "After filling in the vaules, run this script again."
	exit
fi

export AUTOMINE_CFG_PATH=cfg/${RIG_HOST}.automine_config.json
$(./show_config.py shell_exports)

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
	SSH_USER=${RIG_USER}@${RIG_HOST}
	SSH_PORT=${LOCAL_SSH_PORT:=22}
fi
DOWNLOAD_DIR=${HOME}/Downloads/${RIG_TYPE}
[ ${RIG_TYPE} == 'nvidia' ] && ETHASHCUDA=ON || ETHASHCUDA=OFF

