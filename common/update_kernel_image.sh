#!/bin/bash

set -e

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

#update_image 4.10.0-22
update_image 4.8.0-54
