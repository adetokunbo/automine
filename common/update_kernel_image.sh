#!/bin/bash
# Rebuild the kernel image on the rig.

update_image() {
    local image_id=$1
    [[ -z $image_id ]] && {
        echo "Usage: update_image 'image_id'"
        return 1
    }

    sudo apt upgrade
    sudo apt dist-upgrade
    sudo apt-get --fix-missing install \
         linux-headers-$image_id \
         linux-headers-$image_id-generic \
         linux-image-$image_id-generic \
         linux-image-extra-$image_id-generic
    sudo reboot
}

set -e
set -u  # fail if a referenced environment variable is not set
update_image $TARGET_KERNEL
