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
# The logs of ethminer are piped through simple grep commands that append files
# in the alert directory. These files are monitored by systemd which takes the
# appropriate action, e.g, restart the miner.
switched_to_fallback() {
    grep -q "Solution found; Submitting to ${FALLBACK_POOL}" \
        && echo "$(date +%Y/%m/%d::%H:%M:%S)" >> $AUTOMINE_ALERT_DIR/switched_to_fallback.txt
}

detected_launch_failure() {
    grep -q "unspecified launch failure" \
        && echo "$(date +%Y/%m/%d::%H:%M:%S)" >> $AUTOMINE_ALERT_DIR/detected_launch_failure.txt
}

$HOME/bin/ethminer \
    -S ${MAIN_POOL} \
    -FS ${FALLBACK_POOL}  \
    -O "$WALLET"."$WORKER" \
    -U \
    --cuda-grid-size 8192
    --cuda-block-size 64 \
    --cuda-parallel-hash ${CUDA_PARALLEL_HASH:-8} \
    --farm-recheck 200 \
        | tee >(switched_to_fallback) >(detected_launch_failure)
