#/bin/bash

RIG_DIR=$(dirname $SCRIPT_DIR)/$RIG_TYPE
ln -sf ${RIG_DIR}/control_gpus.sh $BIN_DIR/amdgpus

