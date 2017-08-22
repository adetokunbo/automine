#/bin/bash

install_cuda() {
    # Derived from instructions in https://developer.nvidia.com/cuda-downloads
    # https://developer.download.nvidia.com/compute/cuda/repos/ubuntu1604/x86_64/cuda-repo-ubuntu1604_8.0.61-1_amd64.deb

    set -u  # fail if CUDA_VERSION has not been set
    local download_pkg=cuda-repo-${CUDA_VERSION}_amd64.deb
    local download_url=http://developer.download.nvidia.com/compute/cuda/repos/ubuntu1604/x86_64/$download_pkg
    mkdir -p $HOME/.automine/lib/install
    cd $HOME/.automine/lib/install
    [ -f $download_pkg ] || wget $download_url
    sudo dpkg -i $download_pkg
    sudo apt-get -y update
    sudo apt-get -y upgrade
    sudo apt-get -y --fix-missing install build-essential cuda software-properties-common
    set +u
}

set -e
install_cuda


