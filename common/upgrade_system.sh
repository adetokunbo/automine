#!/bin/bash
# Upgrades the system, installing the latest security patches, etc.

upgrade_system() {
    local additional_pkgs=$1
    systemctl --user stop automine
    sudo apt -y update
    sudo apt -y upgrade
    sudo apt -y dist-upgrade
    sudo apt -y autoremove
    [[ -n additional_pkgs ]] && sudo apt -y install $additional_pkgs

    # trigger a reboot where the automine service restarts automatically
    date -u +'upgrd:%Y-%m-%dT%H:%M:%SZ' >> ~/.automine/var/triggers/failed_gpus.txt
}

upgrade_system "$@"
