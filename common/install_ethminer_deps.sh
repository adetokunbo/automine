#/bin/bash

# Add the official ethereum ppa to take care of a lot of the dependencies, even if they might not get used.
sudo apt-get update
sudo apt-get -y install software-properties-common
sudo add-apt-repository -y ppa:ethereum/ethereum
sudo add-apt-repository -y ppa:ethereum/ethereum-qt 
sudo apt-get update
sudo apt-get install -y cpp-ethereum

# 2017/06/12: Thankfully obtained from
# https://forum.ethereum.org/discussion/comment/59189#Comment_59189

sudo apt-get -y install \
     autotools-dev \
     autoconf \
     automake \
     build-essential \
     cmake \
     git \
     libboost-all-dev \
     libcryptopp-dev \
     libcurl4-gnutls-dev \
     libgmp-dev \
     libjsoncpp-dev \
     libleveldb-dev \
     libjsonrpccpp-dev \
     libjsonrpccpp-stub0 \
     libjsonrpccpp-tools \
     libmicrohttpd-dev \
     libminiupnpc-dev \
     libminiupnpc10 \
     libreadline-dev \
     libtool \
     mesa-common-dev \
     m4 \
     ocl-icd-libopencl1 \
     opencl-headers

[ ${RIG_TYPE} == 'nvidia' ] && sudo apt-get -y install cuda
