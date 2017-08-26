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

_sed_replace_vars() {
    for varname in $@
    do
        printf ' -e'
        printf " s|{{\\\$${varname}}}|${!varname}|g"
    done
}

_sed_cp_base() {
    local tee_prefix=$1
    shift
    local src=$1
    shift
    local dst_dir=$1
    shift
    [[ -n $src ]] && [[ -n $dst_dir ]] && (( ${#@} > 0 )) && {
        local tee_cmd="${tee_prefix} tee"
        [[ $tee_prefix == ' ' ]] && tee_cmd="tee"
        echo
        echo 'Before: ..'
        cat $src
        echo
        echo 'After: ...'
        sed $(_sed_replace_vars $@) $src | ${tee_cmd} $dst_dir/${src##*/}
        echo
    }
}

_sed_cp() {
    _sed_cp_base ' ' "$@"
}

_sudo_sed_cp() {
    _sed_cp_base 'sudo' "$@"
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
    _sed_cp ${here}/automine.service $systemd_dir 'RIG_TYPE'
    cp -v ${here}/automine_triggers.service $systemd_dir
    _sed_cp ${here}/automine_triggers.path $systemd_dir 'AUTOMINE_ALERT_DIR'
    cp -v ${here}/automine_track_scan_log.timer $systemd_dir
    _sed_cp ${here}/automine_track_scan_log.service $systemd_dir 'AUTOMINE_ALERT_DIR' 'AUTOMINE_LOG_DIR'
    cp -v ${here}/automine_gpu_health.timer $systemd_dir
    _sed_cp ${here}/automine_gpu_health.service $systemd_dir 'AUTOMINE_ALERT_DIR' 'AUTOMINE_LOG_DIR' 'RIG_TYPE'
    _sed_cp ${here}/automine_needs_reboot.path $systemd_dir 'AUTOMINE_ALERT_DIR'
    _sed_cp ${here}/automine_needs_reboot.service $systemd_dir 'AUTOMINE_ALERT_DIR'
    cp -v ${here}/automine_wait_then_reboot.timer $systemd_dir
    _sed_cp ${here}/automine_wait_then_reboot.service $systemd_dir 'AUTOMINE_ALERT_DIR'
    cp -v ${here}/automine_wait_then_overclock.timer $systemd_dir
    _sed_cp ${here}/automine_wait_then_overclock.service $systemd_dir 'AUTOMINE_ALERT_DIR'
    cp -v ${here}/automine_machine_restart.service $systemd_dir
}

# Update, then copy the overclock systemd units to the superuser systemd
# directory
install_overclock_systemd_units() {
    local here=$(this_dir)
    local systemd_dir=/lib/systemd/system
    sudo cp -v ${here}/automine_overclock.path $systemd_dir
    _sudo_sed_cp ${here}/automine_overclock.service $systemd_dir 'HOME' 'AUTOMINE_LOG_DIR' 'RIG_TYPE'
}

# Update, then copy the reboot systemd units to the superuser systemd
# directory
install_reboot_systemd_units() {
    local here=$(this_dir)
    local systemd_dir=/lib/systemd/system
    _sudo_sed_cp ${here}/automine_reboot.path $systemd_dir 'AUTOMINE_ALERT_DIR'
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
