#!/bin/bash

upgrade_system() {
    systemctl --user stop automine
    sudo apt -y update
    sudo apt -y upgrade
    sudo apt -y dist-upgrade
    sudo apt -y autoremove
    sudo reboot
}

upgrade_system
