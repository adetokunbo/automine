#!/bin/bash

[ -f ~/.screenrc ] || cp -v $HOME/bin/automine/common/.screenrc ~/.screenrc
BIN_DIR=$HOME/bin/automine/amdgpu

echo 'Starting ethminer in a detached screen...'

# Terminate any existing ethminer processes or screens
killall -TERM ethminer >/dev/null 2>&1
kill -TERM `screen -list | grep ethminer | cut -d \. -f 1 | awk {'print $1'}` >/dev/null 2>&1

echo -n "."; sleep 1

# Put a BASH shell on tab 0. Use a custom prompt to let us know we're in screen.
# Good for tweaking variables on a running system.
/usr/bin/screen -AdmS ethminer -t shell bash --rcfile $BIN_DIR/screen_dot_profile

# Run the miner
/usr/bin/screen -S ethminer  -X screen -t ethminer $BIN_DIR/run_ethminer.sh

# Let the desktop have priority for what little CPU it requires.
renice -n -10 `pgrep -f ethminer`

# Start our temperature / fan speed control loop - this is backgrounded and not
# in screen, but we want it after ethminer and before anything reliant on it.
$BIN_DIR/control_fans.sh &

# Watch fans and temperatures on tab 2.
/usr/bin/screen -AS ethminer -X screen -t temperature watch -n5 cat /tmp/gputemp.last

# Watch kernel info on speeds and debug info on tab 3
/usr/bin/screen -AS ethminer -X screen -t amdgpu_pm_info watch -n5 sudo $BIN_DIR/show_gpu_info.sh

# Watch the DPM states on tab 4. Interesting only if you're not forcing state 7.
/usr/bin/screen -AS ethminer -X screen -t amdgpu_dpm watch -n5 sudo cat /sys/class/drm/card*/device/pp_dpm_*clk

# This last will bring up the screen session in which we just launched ethminer
# if it is run from a terminal, and not when the script is run from
# /etc/rc.local on startup.
screen -r -p ethminer

exit 0
