#!/bin/bash
# Overclocks using Nvidia tools (nvidia-smi and nvidia-settings)
#
# Prequisites: should be run as root
#              needs a X display running, and the DISPLAY variable set
#
# Usage:
# ------
# $ sudo DISPLAY=:0 $HOME/bin/automine/nvidia/overclock.sh

this_dir() {
    local script_path="${BASH_SOURCE[0]}"
    if ([ -h "${script_path}" ])
    then
        while([ -h "${script_path}" ])
        do
            script_path=`readlink "${script_path}"`;
        done
    fi
    pushd . > /dev/null
    cd $(dirname ${script_path}) > /dev/null
    script_path=$(pwd);
    popd  > /dev/null
    echo $script_path
}

perform_overclock() {
    # Update CPU performance
    echo "performance" > /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor
    echo "performance" > /sys/devices/system/cpu/cpu1/cpufreq/scaling_governor
    echo 2800000 > /sys/devices/system/cpu/cpu0/cpufreq/scaling_min_freq
    echo 2800000 > /sys/devices/system/cpu/cpu1/cpufreq/scaling_min_freq

    # Update GPUs
    local max_card_index=$(expr $(nvidia-smi -L | wc -l) - 1)
    local settings_cmd='/usr/bin/nvidia-settings -a'
    for i in $(seq 0 $max_card_index)
    do
        echo "Updating card $i power_level=$NVD_POWER_LEVEL fan_speed=$NVD_FAN_SPEED"
        echo "                 GPU Clock offset=$NVD_CLOCK_OFFSET Memory Offset=$NVD_MTR_OFFSET"
        nvidia-smi -i ${i} -pm 1
        nvidia-smi -i ${i} -pl $NVD_POWER_LEVEL
        ${settings_cmd} [gpu:${i}]/GPUPowerMizerMode=1
        ${settings_cmd} [gpu:${i}]/GPUFanControlState=1
        ${settings_cmd} [fan:${i}]/GPUTargetFanSpeed=$NVD_FAN_SPEED
        ${settings_cmd} [gpu:${i}]/GPUGraphicsClockOffset[3]=${NVD_CLOCK_OFFSET}
        ${settings_cmd} [gpu:${i}]/GPUMemoryTransferRateOffset[3]=${NVD_MTR_OFFSET}
    done
}

# Set NVD environment variables to sane defaults if they are not already set
SCRIPT_DIR=$(this_dir)
source $(dirname $SCRIPT_DIR)/cfg.sh
NVD_CLOCK_OFFSET=${NVD_CLOCK_OFFSET:=200}
NVD_POWER_LEVEL=${NVD_POWER_LEVEL:=100}
NVD_MTR_OFFSET=${NVD_MTR_OFFSET:=1750}
NVD_FAN_SPEED=${NVD_FAN_SPEED:=80}
perform_overclock
