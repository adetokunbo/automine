#!/bin/bash

# Adjust AMD GPU fan speeds according to card temperatures.
# Set your TARGET temperature for all GPUs a degree or two lower than what you want it to achieve.
# The script reacts when we exceed that temperature, and will produce results on the high side of
# whatever figure you set here. My default of 49 will produce some fans running at full blast and
# is needed for substantial memory overclocking (2250Mhz); if you're running at lower speeds you
#y can get away with higher GPU temperatures.

THERMOSTAT=68;
[ -r /tmp/gputemp.target ] && THERMOSTAT=`cat /tmp/gputemp.target`;
[ -z $THERMOSTAT ] && THERMOSTAT=68;

# Note the ability to override target temperature by echoing a value to
# /tmp/gputemp.target. On my rig (Sapphire Nitro+ 8GB, twin fans) a value of 58
# will keep the GPU temperatures below 60 with the fans around ~50% (without
# Xorg). A value of 52 will have the fans working close to full blast. If you
# are using higher memory clocks, see the functions below to define minimum fan
# speeds that will apply regardless of GPU temperatures.

function checkgputemp {
    local in_temperature=$1
    local percent=$(bc <<< "scale=2; ($in_temperature/$THERMOSTAT) * 100")
    echo "$percent"
}

# Reworked for running every few seconds. We want to ramp up more aggressively, from a slow start
# at say 100 to 255 if we need it. If you want to hack around in this function, note that TMPI
# is an integer percentage of reported temp versus target temp. Arguably we don't now need half
# of these expressions. Effectively, this says "when temp > 102% of target, up the fan speed by
# 12/255 or about 4%; when temp < 98% of target drop fan speed by ~2%". Later on we'll be running
# this every two seconds, so it ramps up the fan speed pretty fast.

function decidefanspeed {
	TMPP=$1;
	TMPI=`echo $1 | cut -d \. -f 1| bc`;
	FAN=$2
	NEWFAN="$FAN";
	[ "$TMPI" -lt 98 ] && NEWFAN=`expr "$FAN" - 12`;
	[ "$TMPI" -lt 100 ] && NEWFAN=`expr "$FAN" - 6`;
	[ "$TMPI" -gt 100 ] && NEWFAN=`expr "$FAN" + 6`;
	[ "$TMPI" -gt 102 ] && NEWFAN=`expr "$FAN" + 12`;
	[ "$NEWFAN" -gt 255 ] && NEWFAN=255;
	[ "$NEWFAN" -lt 100 ] && NEWFAN=100;
	echo "$NEWFAN";
}

function getminfan {
	GPU=$1
	MEM=$2
	MINFAN=100;
	[ "$GPU" -gt 1099 ] && MINFAN=100;
	[ "$GPU" -gt 1149 ] && MINFAN=129;
	[ "$MEM" -gt 2039 ] && MINFAN=129;
	[ "$GPU" -gt 1199 ] && MINFAN=153;
	[ "$MEM" -gt 2099 ] && MINFAN=153;
	[ "$GPU" -gt 1249 ] && MINFAN=153;
	[ "$MEM" -gt 2199 ] && MINFAN=180;
	[ "$GPU" -gt 1299 ] && MINFAN=204;
	[ "$MEM" -gt 2249 ] && MINFAN=204;
	[ "$GPU" -gt 1349 ] && MINFAN=230;
	[ "$MEM" -gt 2299 ] && MINFAN=230;
	echo "$MINFAN";
}

function getmaxfan {
	GPU=$1
	MEM=$2
	MAXFAN=255;
	[ "$GPU" -lt 1250 ] && [ "$MEM" -lt 2201 ] && MAXFAN=230;
	[ "$GPU" -lt 1200 ] && [ "$MEM" -lt 2101 ] && MAXFAN=182;
	echo "$MAXFAN";
}

# Reworked this to cope with situations where x differs between cardx and hwmonx, as it does when
# I put the cards on my workstation. This will find any instance of hwmonx/pwm1 under the path
# /sys/class/drm/card*/device/hwmon/ so should work for any number of cards. Also now handles
# the possibility of a static fan override that can be set and removed with the 'amdgpus' command
# we create elsewhere.

echo "`date`"
echo;

ls -1 /sys/class/drm/card*/device/hwmon/hwmon*/pwm1 | while read hwmon; do
	TEMP1_INPUT=`echo $hwmon | sed -e "s/pwm1/temp1_input/"`;
	CARD_BASE_PATH=`echo $hwmon | head -c 28`;
	CARD_GPU_CLOCK=`cat "$CARD_BASE_PATH/pp_dpm_sclk" | grep '*' | awk {'print $2'} | sed -e s/M[hH][zZ]// `;
	CARD_MEM_CLOCK=`cat "$CARD_BASE_PATH/pp_dpm_mclk" | grep '*' | awk {'print $2'} | sed -e s/M[hH][zZ]// `;
	NAME=`echo $hwmon | cut -d / -f 5 | sed -e "s/card/GPU #/"`;
	FAN=`cat $hwmon`;
	TEMP1=`cat $TEMP1_INPUT`;
 	TMP=$(($TEMP1/1000));
	FANP=`bc <<< "scale=2; ($FAN/255)*100"`;
        TMPP=$(checkgputemp "$TMP");
        NEWFAN=$(decidefanspeed "$TMPP" "$FAN");
	echo -n "$NAME has temp $TMP" && echo -n $'\xc2\xb0'C && echo -n " at ${CARD_GPU_CLOCK}Mhz GPU and ${CARD_MEM_CLOCK}Mhz memory clock ($TMPP% of target $THERMOSTAT" && echo -n $'\xc2\xb0'C && echo ")";
	MINFAN="$(getminfan "$CARD_GPU_CLOCK" "$CARD_MEM_CLOCK")";
	MAXFAN="$(getmaxfan "$CARD_GPU_CLOCK" "$CARD_MEM_CLOCK")";
	echo " - setting minimum fan speed to $MINFAN/255";
	echo " - setting maximum fan speed to $MAXFAN/255";
	MYFAN="$NEWFAN";
	[ "$NEWFAN" -lt "$MINFAN" ] && MYFAN="$MINFAN";
	[ "$NEWFAN" -gt "$MAXFAN" ] && MYFAN="$MAXFAN";
	NFANP=`bc <<< "scale=2; ($MYFAN/255)*100"`;
#	[ "$NEWFAN" -eq 100 ] && echo " - setting minimum fan speed to 100/255 (40%) even where GPU temp is OK";
	[ -r "/tmp/gpufan.override" ] && MYFAN="`cat /tmp/gpufan.override`" && echo " - overriding fan speed to $MYFAN/255 per /tmp/gpufan.override" ;
        echo " - setting current fan speed from $FAN/255 ($FANP%) to $MYFAN/255 ($NFANP%)";
	echo "";
        sudo echo "$MYFAN" > $hwmon;
done;
