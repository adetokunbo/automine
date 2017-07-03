#!/bin/bash

this_dir() {
    local script_path="${BASH_SOURCE[0]}"
    if ([ -h "${script_path}" ])
    then
        while([ -h "${script_path}" ])
        do
            script_path=`readlink "${script_path}"`;
        done
    fi
    pushd . > /dev/null
    cd $(dirname ${script_path}) > /dev/null
    script_path=$(pwd);
    popd  > /dev/null
    echo $script_path
}

SCRIPT_DIR=$(this_dir)
source $(dirname $SCRIPT_DIR)/cfg.sh
set -u
echo "Mining to ${WALLET}.${WORKER} at ${MAIN_POOL} || ${FALLBACK_POOL}"
set +u

$HOME/bin/ethminer -U \
    -S ${MAIN_POOL} \
    -FS ${FALLBACK_POOL}  \
    -O "$WALLET"."$WORKER" \
    --cuda-grid-size 8192
    --cuda-block-size 64 \
    --cuda-parallel-hash 8 \
    --farm-recheck 200
