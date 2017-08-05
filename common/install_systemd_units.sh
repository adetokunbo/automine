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
    loginctl enable-linger $LOG_NAME
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
    cp -v ${here}/automine_triggers.path $systemd_dir
    cp -v ${here}/automine_track_scan_log.timer $systemd_dir
    cp -v ${here}/automine_track_scan_log.service $systemd_dir
    cp -v ${here}/automine_gpu_health.timer $systemd_dir
    sed -e "s/{{\$RIG_TYPE}}/$RIG_TYPE/g" \
        ${here}/automine_gpu_health.service \
        | tee $systemd_dir/automine_gpu_health.service
    cp -v ${here}/automine_needs_reboot.path $systemd_dir
    cp -v ${here}/automine_needs_reboot.service $systemd_dir
    cp -v ${here}/automine_wait_then_reboot.timer $systemd_dir
    cp -v ${here}/automine_wait_then_reboot.service $systemd_dir
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
    echo 'After: ...'
    sed -e "s|{{\$HOME}}|$HOME|g" \
        -e "s/{{\$RIG_TYPE}}/$RIG_TYPE/g" \
        ${here}/automine_overclock.service \
        | sudo tee $systemd_dir/automine_overclock.service
    mkdir -p /tmp/automine
}

# Update, then copy the reboot systemd units to the superuser systemd
# directory
install_reboot_systemd_units() {
    local here=$(this_dir)
    local systemd_dir=/lib/systemd/system
    sed -e "s|{{\$HOME}}|$HOME|g" \
        ${here}/automine_reboot.path \
        | sudo tee $systemd_dir/automine_reboot.path
    sudo cp -v ${here}/automine_reboot.service $systemd_dir
    mkdir -p /tmp/automine
}

# Enable the systemd trigger services
enable_triggers_and_timers() {
    sudo systemctl daemon-reload
    systemctl --user --now enable automine_triggers.path
    systemctl --user --now enable automine_needs_reboot.path
    systemctl --user --now enable automine_gpu_health.timer
    sudo systemctl --now enable automine_overclock.path
    sudo systemctl --now enable automine_reboot.path
}

# Ensure there's a persistent systemd journal
ensure_persistent_journal() {
    sudo mkdir -p /var/log/journal
}

set -e
cp_user_systemd_units
enable_user_systemd_services
ensure_persistent_journal
install_overclock_systemd_units
install_reboot_systemd_units
enable_triggers_and_timers
