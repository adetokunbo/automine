#/bin/bash
sudo apt-get -y update
sudo apt-get -y upgrade
sudo apt-get -y install build-essential software-properties-common

CUDA_VERSION=ubuntu1404_8.0.44-1
mkdir -p $HOME/tmp
cd $HOME/tmp
wget http://developer.download.nvidia.com/compute/cuda/repos/ubuntu1404/x86_64/cuda-repo-${CUDA_VERSION}_amd64.deb
sudo dpkg -i cuda-repo-${CUDA_VERSION}_amd64.deb
