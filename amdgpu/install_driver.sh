#/bin/bash

# TODO: update remote script to set the DRIVER_VERSION when calling amdgpu/install_driver.sh
#DRIVER_VERSION=17.10-414273
#DRIVER_VERSION=16.30.3-306809
#DRIVER_VERSION=16.60-379184
DRIVER_VERSION=${DRIVER_VERSION:=16.40-348864}

CURRENT_DIR=$(pwd)
mkdir -p $HOME/tmp
cd $HOME/tmp
tar -Jxvf  ~/var/downloads/amdgpu/amdgpu-pro-${DRIVER_VERSION}.tar.xz
cd amdgpu-pro-${DRIVER_VERSION}
./amdgpu-pro-install  # takes 5-10 mins
cd $CURRENT_DIR
source install_sdk.sh



