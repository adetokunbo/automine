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
[[ -z $WALLET ]] && {
    echo "WALLET not defined in the environment"
    exit 1
}
[[ -z $WORKER ]] && {
    echo "WORKER not defined in the environment"
    exit 1
}
[[ -z $MAIN_POOL ]] && {
    echo "MAIN_POOL not defined in the environment"
    exit 1
}
[[ -z $FALLBACK_POOL ]] && {
    echo "FALLBACK_POOL not defined in the environment"
    exit 1
}
MINER_BIN=$HOME/bin/ethminer

set -x
$MINER_BIN -U \
    -S ${MAIN_POOL} \
    -FS ${FALLBACK_POOL}  \
    -O "$WALLET"."$WORKER" \
    --cuda-grid-size 16384 \
    --cuda-block-size 128 \
    --cuda-streams 4 \
    --farm-recheck 200
set +x
