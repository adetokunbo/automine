#!/bin/bash

echo 'Starting ethminer in a detached screen...'

# Terminate any existing ethminer or screens
#
# - for safety only; this should have been done already if this script is invoked via
# its systemctl service
killall -TERM ethminer >/dev/null 2>&1
kill -TERM `screen -list | grep ethminer | cut -d \. -f 1 | awk {'print $1'}` >/dev/null 2>&1

echo -n "."; sleep 1

# Put a BASH shell on tab 0.  Good for examining a running system
/usr/bin/screen -AdmS ethminer -t shell bash

# Start a vncserver.  This works because the /etc/X11/xorg.conf is set up to allow headless access
/usr/bin/screen -S ethminer -X screen -t vncserver x0vncserver -display :0 -passwordfile $HOME/.vnc/passwd

# Run the miner in tab 1
/usr/bin/screen -S ethminer -X screen -t ethminer $HOME/bin/automine/nvidia/run_ethminer.sh

# Show the result of running nvidia-smi on tab 4
/usr/bin/screen -AS ethminer -X screen -t nvidia_smi watch -n60 nvidia-smi

# This last will bring up the screen session in which we just launched ethminer
# if it is run from a terminal, and not when the script is run from
# /etc/rc.local on startup.
screen -r -p ethminer

exit 0



