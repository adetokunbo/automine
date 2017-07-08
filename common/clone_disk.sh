#!/bin/bash
# Clones one disk to another, defaulting from /dev/sda to /dev/sdb

detect_device() {
    local name=${1:-notspecified}
    lsblk -S -n --output NAME | grep -q $name || {
        echo "Did not detect block device $name"
        return 1
    }
    return 0
}

clone_disk() {
    local dst=${1:-sdb}
    local src=${2:-sda}
    detect_device $dst || return 1
    detect_device $src || return 1
    sudo apt -y update
    sudo apt -y install gddrescue
    echo "*** Warning: Disk clone may take a while (>30mins) ****"
    sudo ddrescue -fv /dev/${src} /dev/${dst}
}

set -e
clone_disk "$@"
