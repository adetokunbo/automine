#!/bin/bash

source ssh_ensure_env.sh

# Ensure the runtime directories are present
_ensure_rig_runtime_dirs() {
    ssh ${SSH_USER} -p${SSH_PORT} mkdir -p \~/bin
    ssh ${SSH_USER} -p${SSH_PORT} mkdir -v -m 777 -p \~/.automine/var/{logs,triggers}
    ssh ${SSH_USER} -p${SSH_PORT} mkdir -v -m 755 -p \~/.automine/{var/src,lib/install}
}

# Sync the scripts and rig config
_sync_scripts_and_rig_config() {
    cp ${AUTOMINE_CFG_PATH} automine_config.json
    rsync -avz -e "ssh -p ${SSH_PORT}" --del --exclude=cfg/* . ${SSH_USER}:~/bin/automine
    rm automine_config.json
}

# Add the symlinks used in the commands
_add_command_symlinks() {
    ssh ${SSH_USER} -p${SSH_PORT} ln -sf \~/bin/automine/logging_config.json \~/.automine/var/logs
    ssh ${SSH_USER} -p${SSH_PORT} ln -sf \~/bin/automine/automine_config.json \~/.automine/
    ssh ${SSH_USER} -p${SSH_PORT} ln -sf \~/bin/automine/show_config.py \~/bin/automine_show_config
    ssh ${SSH_USER} -p${SSH_PORT} ln -sf \~/bin/automine/dispatch_command.sh \~/bin/automine_run
}

# Copy the the AMDGPU SDK from the host machine
#
# For the install_driver command, it is necessary to copy the AMDGPU SDK from
# the host.
#
# This is because the AMDGPU site does not allow the SDK to be obtained directly
# via wget. Since this is the only command that requires host-side set-up, it's
# done in a conditional branch here
_maybe_sync_amdgpu_sdk() {
    local this_command=$1
    if [[ $this_command == "install_driver" && $RIG_TYPE == "amdgpu" ]]
    then
        local basename=AMD-APP-SDKInstaller-${AMDGPU_SDK_VERSION}-linux64.tar.bz2
        local src=${AUTOMINE_DOWNLOAD_DIR}/$basename
        [[ -f $src ]] || {
            echo
            echo "Cannot install AMDGPU driver and SDK: SDK not download to this host"
            echo
            echo "Please manually download AMDGPU SDK version $AMDGPU_SDK_VERSION"
            echo "from http://developer.amd.com/amd-accelerated-parallel-processing-app-sdk/"
            echo "and save it in the configured download dir: ${AUTOMINE_DOWNLOAD_DIR}"
            echo
            return 1
        }
        local target=${SSH_USER}:\~/.automine/lib/install/
        echo "copying from $src to $target"
        scp -p${SSH_PORT} $src $target
    fi
}

set -u  # fail if any environment variable is not set

_ensure_rig_runtime_dirs
_sync_scripts_and_rig_config
_add_command_symlinks
_maybe_sync_amdgpu_sdk $1
