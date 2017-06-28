#!/bin/bash

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
    local all_devices=$(ls -1 /sys/class/drm/card*/device/hwmon/hwmon*/name)
    for i in $all_devices
    do
        local maker_name=$(cat $i)
        local device_base=$(echo $i | head -c 20)
        if [[ $maker_name == "amdgpu" ]]
        then
            local memory_overdrive_file=${device_base}/device/pp_mclk_od
            local clock_limit_file=${device_base}/device/pp_dpm_sclk
            local manage_power_file=${device_base}/device/power_dpm_force_performance_level

            # Overclock the memory, then manual drop the gpu clock to limit the power
            echo $AMD_MEM_CLOCK_OVERDRIVE | sudo tee ${memory_overdrive_file}
            echo "manual" | sudo tee ${manage_power_file}
            echo $AMD_GPU_CLOCK_LIMIT | sudo tee ${clock_limit_file}
        fi
    done
}

# Set AMD environment variables to sane defaults if they are not already set
set -e
SCRIPT_DIR=$(this_dir)
source $(dirname $SCRIPT_DIR)/cfg.sh
AMD_MEM_CLOCK_OVERDRIVE=${AMD_MEM_CLOCK_OVERDRIVE:=20}
AMD_GPU_CLOCK_LIMIT=${AMD_GPU_CLOCK_LIMIT:=7}
perform_overclock
