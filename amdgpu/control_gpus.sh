#!/bin/bash

# Set, show, watch, etc?
ACTION=$1
# Which control are we performing the action on?
OBJECT=$2
# What value do we intend to set, if applicable?
VALUE=$3
# Identify what we're trying to operate on first
# Find sysfs interfaces to amdgpu cards
echo "" > /tmp/amdgpucards
ls -1 /sys/class/drm/card*/device/hwmon/hwmon*/name | while read possible; do
        NAME=`cat "$possible"`;
        [[ "$NAME" == "amdgpu" ]] && BASE=`echo "$possible" | head -c 20` && TARGETS="$TARGETS $BASE" && echo "$TARGETS" > /tmp/amdgpucards;
        [[ "$1" == "list" ]] && echo "found amdgpu sysfs interface at $BASE";
        [[ "$1" == "get" ]] && [[ $2 == "temps" ]] && OBJ="`echo $possible | sed -e s/name/temp1_input/g`" && echo "`cat $OBJ|head -c2`";
        [[ "$1" == "get" ]] && [[ $2 == "fans" ]] && OBJ="`echo $possible | sed -e s/name/pwm1/g`" && echo "`cat $OBJ`";
        [[ "$1" == "set" ]] && [[ $2 == "fans" ]] && OBJ="`echo $possible | sed -e s/name/pwm1/g`" && echo "$VALUE" > "$OBJ";
        [[ "$1" == "set" ]] && [[ $2 == "pp_sclk_od" ]] && OBJ="$BASE/device/pp_sclk_od" && echo "$VALUE" > "$OBJ"; 
        [[ "$1" == "set" ]] && [[ $2 == "pp_mclk_od" ]] && OBJ="$BASE/device/pp_mclk_od" && echo "$VALUE" > "$OBJ"; 
        [[ "$1" == "get" ]] && [[ $2 == "pp_sclk_od" ]] && OBJ="$BASE/device/pp_sclk_od" && echo "`cat $OBJ`"; 
        [[ "$1" == "get" ]] && [[ $2 == "pp_dpm_sclk" ]] && OBJ="$BASE/device/pp_dpm_sclk" && echo "`cat $OBJ`"; 
        [[ "$1" == "get" ]] && [[ $2 == "pp_dpm_mclk" ]] && OBJ="$BASE/device/pp_dpm_mclk" && echo "`cat $OBJ`";
# Handle manual override of DPM states. 
        [[ "$1" == "set" ]] && [[ "$2" == "pp_dpm_sclk" ]] && [[ "$3" == "auto" ]] && OBJ="$BASE/device/power_dpm_force_performance_level" && echo "$VALUE" > "$OBJ"; 
        [[ "$1" == "set" ]] && [[ "$2" == "pp_dpm_sclk" ]] && [[ "$3" == "manual" ]] && OBJ="$BASE/device/power_dpm_force_performance_level" && echo "$VALUE" > "$OBJ"; 
        [[ "$1" == "set" ]] && [[ "$2" == "pp_dpm_sclk" ]] && [[ "$3" != "auto" ]] && [[ "$3" != "manual" ]] && OBJ="$BASE/device/pp_dpm_sclk" && echo "$VALUE" > "$OBJ"; 
        done;
        TARGETS=`cat /tmp/amdgpucards`;
#       echo "found amdgpu-pro adapters at$TARGETS";
        [[ "$1" == "watch" ]] && [[ $2 == "pp_dpm_sclk" ]] && watch -n0.1 cat /sys/class/drm/card*/device/pp_dpm_sclk; 
        [[ "$1" == "watch" ]] && [[ $2 == "pp_dpm_*clk" ]] && watch -n0.1 cat /sys/class/drm/card*/device/pp_dpm_*clk; 
# Requires magick's GPU temperature management script
        [[ "$1" == "set" ]] && [[ $2 == "temp_target" ]] && OBJ="/tmp/gputemp.target" && echo "$VALUE" > "$OBJ"; 
        [[ "$1" == "get" ]] && [[ $2 == "temp_target" ]] && OBJ="/tmp/gputemp.target" && echo "`cat $OBJ`"; 
        [[ "$1" == "set" ]] && [[ $2 == "fan_override" ]] && OBJ="/tmp/gpufan.override" && echo "$VALUE" > "$OBJ"; 
        [[ "$1" == "set" ]] && [[ $2 == "fan_override" ]] && OBJ="/tmp/gpufan.override" && [[ "$VALUE" == "none" ]] && rm -f "$OBJ" 2>&1; 
        [[ "$1" == "get" ]] && [[ $2 == "fan_override" ]] && OBJ="/tmp/gpufan.override" && [[ -r "$OBJ" ]] && echo "`cat $OBJ`"; 
        [[ "$1" == "get" ]] && [[ $2 == "fan_override" ]] && OBJ="/tmp/gpufan.override" && [[ ! -r "$OBJ" ]] && echo "none"; 
# Report back
        [[ "$1" == "set" ]] && [[ $2 == "pp_sclk_od" ]] && sleep 1 && "$0" get pp_dpm_sclk; 
        [[ "$1" == "set" ]] && [[ $2 == "pp_dpm_sclk" ]] && sleep 1 && "$0" get pp_dpm_sclk

