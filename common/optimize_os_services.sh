#!/bin/bash
# Corrects the grub cmdline to ensure a stable network interface name whenever
# the number of GPUs changes.
#
# Also:
#   Updates the SSHD config, to block any password log-ons
#   Installs a minimal amount of security-focused software


set -e

# Update grub to add custom commands that
#
# 1. prevent the network interface name from changing.
# 2. force acpi reboots
#
# Without 1), on some motherboards, each time a PCI devices is added, the
# network connection stops working because the ethernet device name has changed
#
# Without 2), often 'sudo reboot' only does a soft reboot that fails to
# shutdown, reset and restart key services like SSH.
fix_grub() {
    echo 'Preventing rename interfaces from eth0 in /etc/default/grub ...'
    sudo sed -i'' \
         -e s/GRUB_CMDLINE_LINUX=.*/GRUB_CMDLINE_LINUX='"net.ifnames=0 biosdevname=0 acpi=force reboot=acpi"'/ \
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

fix_sshd_config() {
    echo 'Before: ..'
    cat /etc/ssh/sshd_config | grep -A 2 -B 2 'PasswordAuthentication'
    echo
    sudo sed -i'' \
         -e "s/.*PasswordAuthentication\\s*yes/PasswordAuthentication no/" \
         /etc/ssh/sshd_config
    echo 'After: ...'
    cat /etc/ssh/sshd_config | grep -A 2 -B 2 'PasswordAuthentication'
    echo
    sudo service ssh restart
}

fix_grub_and_etc() {
    local device_count=$(cat /proc/net/dev | tail -n +3 | wc -l)
    (( $device_count==2 )) || {
        echo "This tool only works if there are just 2 interfaces; lo and another"
        echo "There are ${device_count} interfaces; please update them manually"
        return 0
    }
    fix_grub
    fix_etc_to_use_eth0
}

conf_rk_hunter() {
    # [rkunter](https://help.ubuntu.com/community/RKhunter) This helps check for
    # rootkits.  Updating the configuration allows it to be run daily
    echo 'Before: ..'
    cat /etc/default/rkhunter
    echo
    sudo sed -i'' \
         -e "s/^CRON_DAILY_RUN=.*/CRON_DAILY_RUN='yes'/" \
         -e "s/^APT_AUTOGEN=.*/APT_AUTOGEN='yes'/" \
         /etc/default/rkhunter
    echo 'After: ...'
    cat /etc/default/rkhunter
    echo
    sudo rkhunter --propupd
}

conf_chkrootkit() {
    # [chkrootkit](https://hostpresto.com/community/tutorials/how-to-install-and-use-chkrootkit-on-ubuntu-14-04/)
    # This helps check for rootkits. Updating the configuration allows it to be
    # run regularly
    echo 'Before: ..'
    cat /etc/chkrootkit.conf
    echo
    sudo sed -i'' \
         -e "s/^RUN_DAILY=.*/RUN_DAILY='true'/" \
         /etc/chkrootkit.conf
    echo 'After: ...'
    cat /etc/chkrootkit.conf
    echo
    sudo rkhunter --propupd
}

install_simple_security() {
    sudo apt -y update
    sudo apt -y install rkhunter chkrootkit fail2ban

    # [fail2ban](http://www.fail2ban.org/wiki/index.php/MANUAL_0_8)
    # On Ubuntu 16.04, the default installation is good for blocking ssh intrusions
    # conf_fail2ban

    conf_rk_hunter
    conf_chkrootkit
}

fix_grub_and_etc
fix_sshd_config
install_simple_security

