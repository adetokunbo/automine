#!/bin/bash
# Overclocks a single Nvidia GPU (nvidia-smi and nvidia-settings)
#
# Prequisites: should be run as root
#              needs a X display running, and the DISPLAY variable set
#
# Usage:
# ------
# Intended to be used from overclock.sh and overclock.py

perform_one_overclock() {
    NVD_APPLICATION_SETTINGS=${NVD_APPLICATION_SETTINGS:=''}

    set -u  # fail if any required NVD environment variables is not set
    local settings_cmd='/usr/bin/nvidia-settings -a'
    echo "Updating card $NVD_GPU_INDEX"
    echo "power_level=$NVD_POWER_LEVEL fan_speed=$NVD_FAN_SPEED"
    echo "GPU Clock offset=$NVD_CLOCK_OFFSET Memory Offset=$NVD_MTR_OFFSET"

    nvidia-smi -i ${NVD_GPU_INDEX} -pm 1
    nvidia-smi -i ${NVD_GPU_INDEX} -pl $NVD_POWER_LEVEL
    [ -z ${NVD_APPLICATION_SETTINGS+x} ] || nvidia-smi -i ${NVD_GPU_INDEX} -ac ${NVD_APPLICATION_SETTINGS}
    ${settings_cmd} [gpu:${NVD_GPU_INDEX}]/GPUPowerMizerMode=1
    ${settings_cmd} [gpu:${NVD_GPU_INDEX}]/GPUFanControlState=1
    ${settings_cmd} [fan:${NVD_GPU_INDEX}]/GPUTargetFanSpeed=$NVD_FAN_SPEED
    ${settings_cmd} [gpu:${NVD_GPU_INDEX}]/GPUGraphicsClockOffset[3]=${NVD_CLOCK_OFFSET}
    ${settings_cmd} [gpu:${NVD_GPU_INDEX}]/GPUMemoryTransferRateOffset[3]=${NVD_MTR_OFFSET}
    set +u
}

perform_one_overclock
