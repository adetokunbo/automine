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

export GPU_FORCE_64BIT_PTR=1
export GPU_USE_SYNC_OBJECTS=1
export GPU_MAX_ALLOC_PERCENT=100
export GPU_SINGLE_ALLOC_PERCENT=100
export GPU_MAX_HEAP_SIZE=100

set -x
$HOME/bin/ethminer \
    -S asia1.ethermine.org:4444 \
    -FS us2.ethermine.org:4444 \
    -O "$WALLET"."$WORKER" \
    -G \
    --cl-local-work 128 \
    --cl-global-work 16384 \
    --farm-recheck 200
set +x
