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
cp_systemd_units() {
    local here=$(this_dir)
    local systemd_dir=${HOME}/.config/systemd/user
    mkdir -p $systemd_dir
    cp -v ${here}/automine.service $systemd_dir
    cp -v ${here}/automine_triggers.service $systemd_dir
    cp -v ${here}/automine_triggers.path $systemd_dir
}

# enable the systemd trigger services
enable_and_start() {
    systemctl --user enable automine_triggers.path
    systemctl --user start automine_triggers.path
}

set -e
cp_systemd_units
enable_user_systemd_services
enable_and_start
