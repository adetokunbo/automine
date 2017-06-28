#!/bin/bash
set -e

# Update grub to add custom commands that prevent the network interface
# name from changing.
#
# Without this, on some motherboards, each time a PCI devices is added, the
# network connection stops working because the ethernet device name has changed
fix_grub_to_use_eth0() {
    echo 'Preventing rename interfaces from eth0 in /etc/default/grub ...'
    sudo sed -i'' \
         -e s/GRUB_CMDLINE_LINUX=.*/GRUB_CMDLINE_LINUX='"net.ifnames=0 biosdevname=0"'/ \
         /etc/default/grub
    echo ''
    cat /etc/default/grub
    sudo update-grub
}

fix_etc_to_use_eth0() {
    echo 'Updating /etc/network/interface ...'
    echo 'Before: ..'
    cat /etc/network/interfaces
    local old=$(cat /proc/net/dev | tail -n +3 | grep -v lo: | awk {'print $1'} | sed -e s'/.$//')
    sudo sed -i'' \
         -e s/$old/eth0/g \
         /etc/network/interfaces
    echo 'After: ...'
    cat /etc/network/interfaces
}

fix_grub_and_etc() {
    local device_count=$(cat /proc/net/dev | tail -n +3 | wc -l)
    (( $device_count==2 )) || {
        echo "This tool only works if there are just 2 interfaces; lo and another"
        echo "There are ${device_count} interfaces; please update them manually"
        return 0
    }
    fix_grub_to_use_eth0
    fix_etc_to_use_eth0
}

fix_grub_and_etc

