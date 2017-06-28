#!/bin/bash

set -e  # fail on any error

# Install ubuntu-desktop it comes with vnc client called vino
install_ubuntu_desktop() {
    echo 'Installing ubuntu-desktop  ...'
    sudo apt-get -y update
    sudo apt-get -y upgrade
    sudo apt-get -y install ubuntu-desktop vnc4server
}

# Set up an automatic login to LightDM (cf. http://bit.ly/2t5bVU6)
setup_automatic_login() {
    echo "Setup $LOGNAME to autologin to lightdm"
    sudo tee /etc/lightdm/lightdm.conf <<End-of-message
[Seat:*]
autologin-user=$LOGNAME
End-of-message
}

# Execute the functions
install_ubuntu_desktop
setup_automatic_login
