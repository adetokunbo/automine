#!/bin/bash
# Updates the hostname of the rig.

current_hostname() {
    cat /etc/hostname
}

update_hostname() {
    local new=${1:-rig00}
    local current=$(current_hostname)
    echo "Updating hostname from $current to $new"
    [ $new == $current ] && {
        echo "no change required"
        return 0
    }
    sudo sed -i'' \
         -e "s/$current/$new/g" \
         /etc/hosts
    echo $new | sudo tee /proc/sys/kernel/hostname
    echo $new | sudo tee /etc/hostname
    sudo hostname $new
}

update_hostname "$@"
