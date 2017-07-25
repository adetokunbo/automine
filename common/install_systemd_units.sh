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
    cp -v ${here}/automine.service $systemd_dir
    cp -v ${here}/automine_triggers.service $systemd_dir
    cp -v ${here}/automine_triggers.path $systemd_dir
    cp -v ${here}/automine_gpu_health.timer $systemd_dir
    cp -v ${here}/automine_gpu_health.service $systemd_dir
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

# enable the systemd trigger services
enable_and_start() {
    systemctl --user enable automine_triggers.path
    systemctl --user start automine_triggers.path
    systemctl --user enable automine_gpu_health.timer
    systemctl --user start automine_gpu_health.timer
    sudo systemctl enable automine_overclock.path
    sudo systemctl start automine_overclock.path
}

set -e
cp_user_systemd_units
enable_user_systemd_services
install_overclock_systemd_units
enable_and_start
