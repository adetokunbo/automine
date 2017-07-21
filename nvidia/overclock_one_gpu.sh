#!/bin/bash
# Overclocks a single Nvidia GPU (nvidia-smi and nvidia-settings)
#
# Prequisites: should be run as root
#              needs a X display running
#
# Usage:
# ------
# Intended to be used from overclock.sh and overclock.py
# DISPLAY takes its value from the environment but defaults to ':0'

perform_one_overclock() {
    NVD_APPLICATION_SETTINGS=${NVD_APPLICATION_SETTINGS:=''}
    export DISPLAY=${DISPLAY:=':0'}

    set -u  # fail if any required NVD environment variables is not set
    local settings_cmd='/usr/bin/nvidia-settings -a'
    printf "GPU #$NVD_GPU_INDEX targets:"
    printf " power level->$NVD_POWER_LEVEL fan speed->$NVD_FAN_SPEED"
    printf " clock offset->$NVD_CLOCK_OFFSET memory offset->$NVD_MTR_OFFSET\n"

    nvidia-smi -i ${NVD_GPU_INDEX} -pm 1
    nvidia-smi -i ${NVD_GPU_INDEX} -pl $NVD_POWER_LEVEL
    [ -z ${NVD_APPLICATION_SETTINGS} ] || nvidia-smi -i ${NVD_GPU_INDEX} -ac ${NVD_APPLICATION_SETTINGS}
    ${settings_cmd} [gpu:${NVD_GPU_INDEX}]/GPUPowerMizerMode=1
    ${settings_cmd} [gpu:${NVD_GPU_INDEX}]/GPUFanControlState=1
    ${settings_cmd} [fan:${NVD_GPU_INDEX}]/GPUTargetFanSpeed=$NVD_FAN_SPEED
    ${settings_cmd} [gpu:${NVD_GPU_INDEX}]/GPUGraphicsClockOffset[3]=${NVD_CLOCK_OFFSET}
    ${settings_cmd} [gpu:${NVD_GPU_INDEX}]/GPUMemoryTransferRateOffset[3]=${NVD_MTR_OFFSET}
    set +u
}

perform_one_overclock
