#!/bin/bash
# Creates an edid using the instructions here: http://bit.ly/2saRBPy

set -e

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

# Install edid tools.
install_edid_tools() {
    sudo apt -y update
    sudo apt -y upgrade
    sudo apt -y install read-edid edid-decode
}

# Create/Copy edid.bin.
#
# Args: extract_edid
#
# If a physical monitor is connected when this command is run and extract_edid
# is set, it attempts to use get-edid to create edid.bin.
#
# If extract_edid is not set, or the attempt to create the edid fails, it copies
# a pre-generated edid.bin from the data directory
ensure_edid_bin() {
    local extract_edid=$1
    local script_dir=$(this_dir)
    local data_dir=$(dirname $script_dir)/data

    if [[ -n ${extract_edid} ]]
    then
        echo "configure_xorg: attempting to create an edid.bin because '${extract_edid}' is set"
        install_edid_tools
        mkdir -p $HOME/tmp
        sudo get-edid -m 0 > $HOME/tmp/edid.bin || cp -v $data_dir/edid.bin $HOME/tmp/edid.bin
        cat $HOME/tmp/edid.bin | edid-decode
    else
        echo "configure_xorg: using the pre-created edid.bin"
        cp -v $data_dir/edid.bin $HOME/tmp/edid.bin
    fi
    [[ -f /etc/X11/edid.bin ]] && sudo cp /etc/X11/edid.bin /etc/X11/edid.bin.bak
    sudo cp -v $HOME/tmp/edid.bin /etc/X11/edid.bin
}

# Create an xorg.conf using nvidia-xconfig.
#
# If no physical Monitor is connected when this command is run, it will be
# necessary necessary for the BIOS to be updated to prefer the PCI devices to
# IGF (integrated graphics) devices before rebooting.
regenerate_xconfig() {
    sudo nvidia-xconfig -a --cool-bits 28 --custom-edid=DFP-0:/etc/X11/edid.bin --use-edid-dpi --connected-monitor=DFP-0
}

restart_lightdm() {
    echo "configure_xorg: restarting lightdm to use the new xorg config"
    sudo service lightdm restart
}

ensure_edid_bin "$@"
regenerate_xconfig
restart_lightdm
