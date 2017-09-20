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

set -u
eval $($HOME/bin/automine_show_config shell_exports)
eval $($HOME/bin/automine_show_config ethminer_exports)
export AUTOMINE_ALERT_DIR=${AUTOMINE_RUNTIME_DIR}/triggers
export AUTOMINE_LOG_DIR=${AUTOMINE_RUNTIME_DIR}/logs
set +u

# Maybe trigger an update of the overclocks
[[ -f ${AUTOMINE_ALERT_DIR}/overclock_on_restart.txt ]] && /bin/systemctl --user start automine_wait_then_overclock.timer

# Monitor with simple alerts from grepping the logs.
#
# The scan log tool performs a simple grep of known errors and updates files in
# the alert directory when it detects them. These files are monitored by systemd
# which takes the appropriate action, e.g, restart the miner.
SCAN_LOG=$(dirname $(this_dir))/common/scan_log.py
echo "Scanning logs with $SCAN_LOG"
$HOME/bin/ethminer $($HOME/bin/automine_show_config ethminer_opts) 2>&1 | tee >($SCAN_LOG)
