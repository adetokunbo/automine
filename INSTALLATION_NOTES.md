#!/bin/bash

# show all mac drives
disktutil ls

# setup ethereum

# Update packages
sudo apt upgrade
sudo apt dist-upgrade

# Download the amdgpu drive
# Optional: dpkg -l amdgpu-pro
# This is not needed; it's a check to see if an AD driver is already present.
# That's not the case for a fresh install
mkdir -p ~/var/downloads

# this did not work, the wget download was in invalid
# wget -O ~/var/downloads/amdgpu-pro-17.10-414273.tar.xz  https://www2.ati.com/drivers/linux/ubuntu/amdgpu-pro-17.10-414273.tar.xz

# From Mac
scp ~/Downloads/amdgpu-pro-17.10-414273.tar.xz ${RIG_USER}@{RIG_IP_ADDRESS:-192.168.11.9}:~/var/downloads/amdgpu-pro-17.10-414273.tar.xz

# On Ubuntu
cd /tmp
tar -Jxvf  ~/var/downloads/amdgpu-pro-17.10-414273.tar.xz
cd amdgpu-pro-17.10-414273
./amdgpu-pro-install  # takes 5-10 mins
sudo shutdown -r now  # reboot for some of the changes to take effect

# Add the current user to the video group (creating it, in fact)
sudo usermod -a -G video $LOGNAME
# logout and login again for the group to appear

# On Mac
# -Download the AMD OpenCL SDK via the download flow at http://developer.amd.com/tools-and-sdks/opencl-zone/amd-accelerated-parallel-processing-app-sdk/
# Needs to approve license agreement, so there is no direct download link


# On Ubuntu
# - flash the BIOS, getting the latest MSI driver
# - mentioned in https://forum.ethereum.org/discussion/11404/msi-z170-7-gpu-bios-setting-step-by-step/p1
# - latest driver is found at https://msi.com/Motherboard/support/Z170A-GAMING-PRO-CARBON.html#down-bios
# - driver was
#    - release version: 7A12v18
#    - bios flash filename: E7A12IMS.180
# seemed to flash OK


# On Mac
# Copy the AMD SDK download to the linux box
scp ~/Downloads/AMD-APP-SDKInstaller-v3.0.130.136-GA-linux64.tar.bz2 \
    ${RIG_USER}@{RIG_IP_ADDRESS:-192.168.11.9}:~/var/downloads/AMD-APP-SDKInstaller-v3.0.130.136-GA-linux64.tar.bz2

# On Ubuntu
# Install the AMD SDK
mkdir -p ~/tmp
cd ~/tmp
tar -xf ~/var/downloads/AMD-APP-SDKInstaller-v3.0.130.136-GA-linux64.tar.bz2
sudo ./AMD-APP-SDK-v3.0.130.136-GA-linux64.sh

# Build ethminer
created install_cpp_ethereum_deps.sh
- ran it on the Ubuntu miner OK
created build_genoils_miner.sh
- ran it on the Ubuntu miner OK

# Upgrade the kernel
# Base on the following comments, it seems like having an up-to-date kernel 4.4.10-xxx seems a good idea
# https://www.reddit.com/r/EtherMining/comments/6cdpy1/struggling_with_unrecognized_rx580_on_ubuntu/
# https://community.amd.com/thread/210586#2802255

# Step 0

# Check what linux kernel is being used
uname -r
4.4.0-79-generic

# Check what kernels are available, and decide which one to go for
apt-cache search linux-image 
apt-cache search linux-image  | grep '4.10'
apt-cache search linux-image  | grep '4.10.0-22'
linux-image-4.10.0-22-generic - Linux kernel image for version 4.10.0 on 64 bit x86 SMP
linux-image-4.10.0-22-lowlatency - Linux kernel image for version 4.10.0 on 64 bit x86 SMP
linux-image-extra-4.10.0-22-generic - Linux kernel extra modules for version 4.10.0 on 64 bit x86 SMP


# Step 1
# ------
Switched off the machine
Disconnected all the PCI cards
Moved monitor cable to the integrated graphics card
Turned the rig on

# Step 2
# ------
# Removed the AMD drivers
amdgpu-pro-uninstall

# Step 3
# ------
created update_kernel_image.sh
- very quick, takes less than a minute
- ran it on the Ubuntu miner OK
- restarted the Ubuntu miner

Reinstall the AMDGPU drivers
----------------------------
Repeated from above
cd /tmp
tar -Jxvf  ~/var/downloads/amdgpu-pro-17.10-414273.tar.xz
cd amdgpu-pro-17.10-414273
./amdgpu-pro-install  # takes 5-10 mins

This FAILED! (KNOWN ISSUE: https://askubuntu.com/questions/904442/how-to-use-amdgpu-pro-with-17-04, fence.h is removed in 4.10)
 cat /var/lib/dkms/amdgpu-pro/17.10-414273/build/make.log
DKMS make.log for amdgpu-pro-17.10-414273 for kernel 4.10.0-22-generic (x86_64)
Mon Jun 12 08:40:00 JST 2017
make: Entering directory '/usr/src/linux-headers-4.10.0-22-generic'
  LD      /var/lib/dkms/amdgpu-pro/17.10-414273/build/built-in.o
  LD      /var/lib/dkms/amdgpu-pro/17.10-414273/build/amd/amdgpu/built-in.o
  CC [M]  /var/lib/dkms/amdgpu-pro/17.10-414273/build/amd/amdgpu/amdgpu_drv.o
In file included from /var/lib/dkms/amdgpu-pro/17.10-414273/build/amd/amdgpu/../backport/include/kcl/kcl_amdgpu.h:5:0,
                 from /var/lib/dkms/amdgpu-pro/17.10-414273/build/amd/amdgpu/../backport/backport.h:5,
                 from <command-line>:0:
/var/lib/dkms/amdgpu-pro/17.10-414273/build/amd/amdgpu/../amdgpu/amdgpu.h:37:25: fatal error: linux/fence.h: No such file or directory
compilation terminated.
scripts/Makefile.build:294: recipe for target '/var/lib/dkms/amdgpu-pro/17.10-414273/build/amd/amdgpu/amdgpu_drv.o' failed
make[2]: *** [/var/lib/dkms/amdgpu-pro/17.10-414273/build/amd/amdgpu/amdgpu_drv.o] Error 1
scripts/Makefile.build:567: recipe for target '/var/lib/dkms/amdgpu-pro/17.10-414273/build/amd/amdgpu' failed
make[1]: *** [/var/lib/dkms/amdgpu-pro/17.10-414273/build/amd/amdgpu] Error 2
Makefile:1524: recipe for target '_module_/var/lib/dkms/amdgpu-pro/17.10-414273/build' failed
make: *** [_module_/var/lib/dkms/amdgpu-pro/17.10-414273/build] Error 2
make: Leaving directory '/usr/src/linux-headers-4.10.0-22-generic'

# Repeat kernel update with an older version
apt-cache search linux-image 
apt-cache search linux-image  | grep '4.10'
apt-cache search linux-image  | grep '4.8.0-54'
linux-image-4.8.0-54-generic - Linux kernel image for version 4.10.0 on 64 bit x86 SMP
linux-image-4.8.0-54-lowlatency - Linux kernel image for version 4.10.0 on 64 bit x86 SMP
linux-image-extra-4.8.0-54-generic - Linux kernel extra modules for version 4.10.0 on 64 bit x86 SMP

# Restart carefully
- need to select 4.8.0 in GRUB
- then
sudo apt-get remove 4.10.0-22
sudo update-grub

Reinstall the AMDGPU drivers
----------------------------
Repeated from above
cd /tmp
tar -Jxvf  ~/var/downloads/amdgpu-pro-17.10-414273.tar.xz
cd amdgpu-pro-17.10-414273
./amdgpu-pro-install  # takes 5-10 mins

Again re-install AMDGPU drivers after rolling back the kernel
-------------------------------------------------------------
amdgpu-pro-uninstall
sudo apt-get remove 4.10.0-22
dpkg --list | grep linux-image
ii  linux-image-4.4.0-62-generic            4.4.0-62.83                                      amd64        Linux kernel image for version 4.4.0 on 64 bit x86 SMP
ii  linux-image-4.4.0-79-generic            4.4.0-79.100                                     amd64        Linux kernel image for version 4.4.0 on 64 bit x86 SMP
ii  linux-image-4.8.0-54-generic            4.8.0-54.57~16.04.1                              amd64        Linux kernel image for version 4.8.0 on 64 bit x86 SMP
ii  linux-image-extra-4.4.0-62-generic      4.4.0-62.83                                      amd64        Linux kernel extra modules for version 4.4.0 on 64 bit x86 SMP
ii  linux-image-extra-4.4.0-79-generic      4.4.0-79.100                                     amd64        Linux kernel extra modules for version 4.4.0 on 64 bit x86 SMP
ii  linux-image-extra-4.8.0-54-generic      4.8.0-54.57~16.04.1                              amd64        Linux kernel extra modules for version 4.8.0 on 64 bit x86 SMP
sudo apt-get remove 4.8.0-54
sudo update-grub
dpkg --list | grep linux-image

Updating Grub to preserve the eth0 interface name

For some reason, on the Z170X-GAMING3 motherboard, the network interface PCI address comes after all the PCI slots
So the network interface PCI address shifts each time a new card is added.
However, the traditional eth0 name is not being used in ifconfig as of 16.04, instead a new name that is based on the PCI address
This means that every time an PCI slot is used; the network interface PCI address changes, and the network name changes
Which means: that adding a Graphics card kills the internet, as the ifconfig is stuck trying to reboot the wrong network interface

To fix this, follow the advice http://www.itzgeek.com/how-tos/mini-howtos/change-default-network-name-ens33-to-old-eth0-on-ubuntu-16-04.html
which explains how to add a boot parameter that fixes the network interface name.

Invalid Device Ordinal (CUDA error)

Sometimes this happens:

$ ethminer -U --list-devices
...
CUDA error in func 'getNumDevices' at line 112 : invalid device ordinal.
terminate called after throwing an instance of 'std::runtime_error'
what():  invalid device ordinal
Aborted (core dumped)

adetokunbo@nijo-fukae-03:~$ nvidia-smi
Unable to determine the device handle for GPU 0000:02:00.0: Unable to communicate with GPU because it is insufficiently powered.
This may be because not all required external power cables are
attached, or the attached cables are not seated properly.

I.e, it is usually caused by a lack of power - the graphics card had not been plugged in.
#!/bin/bash

# show all mac drives
disktutil ls

# setup ethereum

# Update packages
sudo apt upgrade
sudo apt dist-upgrade

# Download the amdgpu drive
# Optional: dpkg -l amdgpu-pro
# This is not needed; it's a check to see if an AD driver is already present.
# That's not the case for a fresh install
mkdir -p ~/var/downloads

# this did not work, the wget download was in invalid
# wget -O ~/var/downloads/amdgpu-pro-17.10-414273.tar.xz  https://www2.ati.com/drivers/linux/ubuntu/amdgpu-pro-17.10-414273.tar.xz

# From Mac
scp ~/Downloads/amdgpu-pro-17.10-414273.tar.xz ${RIG_IP_ADDRESS:-192.168.11.9}:~/var/downloads/amdgpu-pro-17.10-414273.tar.xz

# On Ubuntu
cd /tmp
tar -Jxvf  ~/var/downloads/amdgpu-pro-17.10-414273.tar.xz
cd amdgpu-pro-17.10-414273
./amdgpu-pro-install  # takes 5-10 mins
sudo shutdown -r now  # reboot for some of the changes to take effect

# Add the current user to the video group (creating it, in fact)
sudo usermod -a -G video $LOGNAME
# logout and login again for the group to appear

# On Mac
# -Download the AMD OpenCL SDK via the download flow at http://developer.amd.com/tools-and-sdks/opencl-zone/amd-accelerated-parallel-processing-app-sdk/
# Needs to approve license agreement, so there is no direct download link


# On Ubuntu
# - flash the BIOS, getting the latest MSI driver
# - mentioned in https://forum.ethereum.org/discussion/11404/msi-z170-7-gpu-bios-setting-step-by-step/p1
# - latest driver is found at https://msi.com/Motherboard/support/Z170A-GAMING-PRO-CARBON.html#down-bios
# - driver was
#    - release version: 7A12v18
#    - bios flash filename: E7A12IMS.180
 
# seemed to flash OK



