#!/bin/bash

# Write the username in your system here
RIG_USER='FILL_THIS_IN'

# For updating the linux kernel
TARGET_KERNEL=4.8.0-54

# "nvidia" or "amdgpu"
RIG_TYPE='FILL_THIS_IN'

# For installing the nvidia driver
CUDA_VERSION=ubuntu1604_8.0.61-1

# Required by the log scanning utility that used in run_ethminer
#
# Don't modify this, it really needs to be set with this value here!
AUTOMINE_ALERT_DIR=$HOME/var/automine/triggers

# Ethminer values
# Your ETH wallet
WALLET='FILL_THIS_IN'

# An arbitraty name of this particular rig, for the pool to know
WORKER='FILL_THIS_IN'

# Choose your main and fallback servers to connect to the Ethermine pool
# North America (East): us1.ethermine.org:4444 or us1.ethermine.org:14444
# North America (West): us2.ethermine.org:4444 or us2.ethermine.org:14444
# Europe (France): eu1.ethermine.org:4444 or eu1.ethermine.org:14444
# Europe (Germany): eu2.ethermine.org:4444 or eu2.ethermine.org:14444
# Asia: asia1.ethermine.org:4444 or asia1.ethermine.org:14444
MAIN_POOL=asia1.ethermine.org:4444
FALLBACK_POOL=us2.ethermine.org:4444

# Optionally, choose the value of --cuda-parallel-hash flag.  This can have an
# an effect on the hash rate when mining with Nvidia cards
CUDA_PARALLEL_HASH=4

# NVIDIA overclock settings
# These are sample overclocking parameters for Nvidia cards
# Used in /nvidia/overclock.sh
NVD_CLOCK_OFFSET=200
NVD_POWER_LEVEL=100
NVD_MTR_OFFSET=1750
NVD_FAN_SPEED=80
