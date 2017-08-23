#!/bin/bash
# Overclocks a single AMDGPU GPU using update to driver files in sysfs
#
# Prequisites: should be run as root
#
# Usage:
# ------
# Intended to be used from overclock.py

perform_one_overclock() {
    set -u   # fail if any required AMD environment variables is not set
    printf "GPU #${AMD_GPU_INDEX} targets:"
    printf " clock offset->$AMD_GPU_CLOCK_LIMIT memory offset->$AMD_MEM_CLOCK_OVERDRIVE\n"
    local sysfs_prefix='/sys/class/drm/card'
    local memory_overdrive_file=${sysfs_prefix}${AMD_GPU_INDEX}/device/pp_mclk_od
    local clock_limit_file=${sysfs_prefix}${AMD_GPU_INDEX}/device/pp_dpm_sclk
    local manage_power_file=${sysfs_prefix}${AMD_GPU_INDEX}/device/power_dpm_force_performance_level

    # Overclock the memory, then manual drop the gpu clock to limit the power
    echo $AMD_MEM_CLOCK_OVERDRIVE | sudo tee ${memory_overdrive_file}
    echo "manual" | sudo tee ${manage_power_file}
    echo $AMD_GPU_CLOCK_LIMIT | sudo tee ${clock_limit_file}
    set +u
}

perform_one_overclock
