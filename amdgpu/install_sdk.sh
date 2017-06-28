#/bin/bash

printf "Installing the AMD SDK"
mkdir -p ~/tmp
cd ~/tmp
tar -xf ~/var/downloads/amdgpu/AMD-APP-SDKInstaller-v3.0.130.136-GA-linux64.tar.bz2
sudo ./AMD-APP-SDK-v3.0.130.136-GA-linux64.sh
