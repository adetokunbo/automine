#!/bin/bash
# Upgrades the system, installing the latest security patches, etc.

# List old kernels that should be removed 
# From http://tuxtweaks.com/2010/10/remove-old-kernels-in-ubuntu-with-one-command/
__list_old_kernel_pkgs() {
    dpkg -l linux-* | awk '/^ii/{ print $2}' | grep -v -e `uname -r | cut -f1,2 -d"-"` | grep -e [0-9] | grep -E "(image|headers)"
}

__remove_old_kernel_pkgs() {
    sudo apt -y update
    sudo apt -y autoremove
    sudo apt -y remove $(__list_old_kernel_pkgs)
}

# upgrade the system
__upgrade() {
    local additional_pkgs="$@"
    sudo apt -y update
    systemctl --user stop automine
    sudo apt -y upgrade
    sudo apt -y dist-upgrade
    [[ -n $additional_pkgs ]] && sudo apt -y install $additional_pkgs
}

# trigger a reboot where the automine service restarts automatically
__trigger_reboot() {
    date -u +'upgrd:%Y-%m-%dT%H:%M:%SZ' >> ~/.automine/var/triggers/failed_gpus.txt
}

# restart the miner
__restart_miner() {
    systemctl --user start automine
}

upgrade_system() {
    OPTIND=1
    local clean_only=0
    local no_reboot=0
    local opt
    while getopts ":xc" opt;
    do
        case $opt in
            x)
                no_reboot=1
                ;;
            c)
                clean_only=1
                ;;
            \?)
                echo "Invalid option: -$OPTARG" >&2
                return 1
                ;;
            :)
                echo "Option -$OPTARG requires an argument." >&2
                return 1
                ;;
        esac
    done
    shift $((OPTIND-1))
    local additional_pkgs="$@"

    __remove_old_kernel_pkgs
    (( $clean_only == 1 )) && return 0
    __upgrade $additional_pkgs
    (( $no_reboot == 1 )) && __restart_miner || __trigger_reboot
}

upgrade_system "$@"
