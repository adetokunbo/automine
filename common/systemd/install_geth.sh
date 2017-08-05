#/bin/bash

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

# Install geth as described in the official instructions
#
# official instructions: https://github.com/ethereum/go-ethereum/wiki/Installation-Instructions-for-Ubuntu
install_geth() {
    sudo apt-get -y update
    sudo apt-get -y install software-properties-common
    sudo add-apt-repository -y ppa:ethereum/ethereum
    sudo apt-get -y update
    sudo apt-get install -y geth
}

# Install the systemd unit for running geth as a systemd service
install_geth_systemd_service() {
    local here=$(this_dir)
    local systemd_dir=${HOME}/.config/systemd/user
    mkdir -p $systemd_dir
    cp -v ${here}/automine_geth.service $systemd_dir
}

# Use loginctl to allow user-owned system services at startup
enable_user_systemd_services() {
    loginctl enable-linger $LOG_NAME
}

# enable the systemd service
enable_geth_service() {
    systemctl --user --now enable automine_geth.service
}

set -e
install_geth
install_geth_systemd_service
enable_user_systemd_services
enable_geth_service
