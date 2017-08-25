#!/bin/bash

function this_dir() {
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

# Use loginctl to allow user-owned system services at startup
enable_user_systemd_services() {
    loginctl enable-linger $LOGNAME
}

# Copy the user systemd configuration files to their required location
cp_user_systemd_units() {
    local here=$(this_dir)
    local systemd_dir=${HOME}/.config/systemd/user
    mkdir -p $systemd_dir
    sed -e "s|{{\$RIG_TYPE}}|$RIG_TYPE|g" \
        ${here}/automine.service \
        | tee $systemd_dir/automine.service

    cp -v ${here}/automine_triggers.service $systemd_dir
    sed -e "s|{{\$AUTOMINE_ALERT_DIR}}|$AUTOMINE_ALERT_DIR|g" \
        ${here}/automine_triggers.path \
        | tee $systemd_dir/automine_triggers.path
    cp -v ${here}/automine_track_scan_log.timer $systemd_dir
    sed -e "s|{{\$AUTOMINE_ALERT_DIR}}|$AUTOMINE_ALERT_DIR|g" \
        -e "s|{{\$AUTOMINE_LOG_DIR}}|$AUTOMINE_LOG_DIR|g" \
        ${here}/automine_track_scan_log.service \
        | tee $systemd_dir/automine_track_scan_log.service
    cp -v ${here}/automine_gpu_health.timer $systemd_dir
    sed -e "s|{{\$AUTOMINE_ALERT_DIR}}|$AUTOMINE_ALERT_DIR|g" \
        -e "s|{{\$AUTOMINE_LOG_DIR}}|$AUTOMINE_LOG_DIR|g" \
        -e "s/{{\$RIG_TYPE}}/$RIG_TYPE/g" \
        ${here}/automine_gpu_health.service \
        | tee $systemd_dir/automine_gpu_health.service
    sed -e "s|{{\$AUTOMINE_ALERT_DIR}}|$AUTOMINE_ALERT_DIR|g" \
        ${here}/automine_needs_reboot.path \
        | tee $systemd_dir/automine_needs_reboot.path
    cp -v ${here}/automine_needs_reboot.service $systemd_dir
    cp -v ${here}/automine_wait_then_reboot.timer $systemd_dir
    sed -e "s|{{\$AUTOMINE_ALERT_DIR}}|$AUTOMINE_ALERT_DIR|g" \
        ${here}/automine_wait_then_reboot.service \
        | tee $systemd_dir/automine_wait_then_reboot.service
    cp -v ${here}/automine_start_with_overclocks.service $systemd_dir
}

# Update, then copy the overclock systemd units to the superuser systemd
# directory
install_overclock_systemd_units() {
    local here=$(this_dir)
    local systemd_dir=/lib/systemd/system
    sudo cp -v ${here}/automine_overclock.path $systemd_dir
    echo 'Before: ..'
    cat ${here}/automine_overclock.service
    echo
    echo 'After: ...'
    sed -e "s|{{\$HOME}}|$HOME|g" \
        -e "s|{{\$AUTOMINE_LOG_DIR}}|$AUTOMINE_LOG_DIR|g" \
        -e "s/{{\$RIG_TYPE}}/$RIG_TYPE/g" \
        ${here}/automine_overclock.service \
        | sudo tee $systemd_dir/automine_overclock.service
    echo
}

# Update, then copy the reboot systemd units to the superuser systemd
# directory
install_reboot_systemd_units() {
    local here=$(this_dir)
    local systemd_dir=/lib/systemd/system
    echo
    sed -e "s|{{\$AUTOMINE_ALERT_DIR}}|$AUTOMINE_ALERT_DIR|g" \
        ${here}/automine_reboot.path \
        | sudo tee $systemd_dir/automine_reboot.path
    echo
    sudo cp -v ${here}/automine_reboot.service $systemd_dir
}

# Enable the systemd trigger services
enable_triggers_and_timers() {
    systemctl --user daemon-reload
    systemctl --user --now reenable automine_triggers.path
    systemctl --user --now reenable automine_needs_reboot.path
    systemctl --user --now reenable automine_gpu_health.timer
    sudo systemctl daemon-reload
    sudo systemctl --now reenable automine_overclock.path
    sudo systemctl --now reenable automine_reboot.path
}

# Ensure there's a persistent systemd journal
ensure_persistent_journal() {
    sudo mkdir -p /var/log/journal
}

set -e  # fail if any subcommand fails
set -u  # fail if any referenced shell variables are unset

# add AUTOMINE_{RT,ALERT,LOG}_DIR to the environment
eval $($HOME/bin/automine_show_config shell_exports)
export AUTOMINE_ALERT_DIR=${AUTOMINE_RUNTIME_DIR}/triggers
export AUTOMINE_LOG_DIR=${AUTOMINE_RUNTIME_DIR}/logs

cp_user_systemd_units
enable_user_systemd_services
ensure_persistent_journal
install_overclock_systemd_units
install_reboot_systemd_units
enable_triggers_and_timers
