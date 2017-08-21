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

reset_rig_env() {
    # static changes
    [ -f ~/tmp/cuda*.deb ] && mv -v ~/tmp/cuda*.deb  ~/.automine/lib/install
    [ -f ~/tmp/edid.bin ] &&  mv -v ~/tmp/edid.bin  ~/.automine/lib/install
    [ -d ~/var/repos/ethminer ] && mv -v ~/var/repos/ethminer ~/.automine/src/

    # changes affecting the running miner
    systemctl --user stop automine
    cp -v  ~/var/automine/triggers/* ~/.automine/var/triggers/
}

set -e
reset_rig_env
