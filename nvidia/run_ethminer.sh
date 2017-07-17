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


# Monitor with simple alerts from grepping the logs.
#
# The scan log tool performs a simple grep of known errors and updates files in
# the alert directory when it detects them. These files are monitored by systemd
# which takes the appropriate action, e.g, restart the miner.
SCAN_LOG=$(dirname $SCRIPT_DIR)/common/scan_log.py
echo "Scanning logs with $SCAN_LOG"
scan_log() {
    # drop the port from FALLBACK_POOL, it's not present in the triggering log line
    FALLBACK_POOL=${FALLBACK_POOL:0:$((${#FALLBACK_POOL}-5))} AUTOMINE_ALERT_DIR=$AUTOMINE_ALERT_DIR $SCAN_LOG
}

$HOME/bin/ethminer \
    -S ${MAIN_POOL} \
    -FS ${FALLBACK_POOL}  \
    -O "$WALLET"."$WORKER" \
    -U \
    --cuda-grid-size 8192 \
    --cuda-block-size 64 \
    --cuda-parallel-hash ${CUDA_PARALLEL_HASH:-8} \
    --farm-recheck 200 2>&1 | tee >(scan_log)
