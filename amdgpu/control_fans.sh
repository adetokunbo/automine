#!/bin/bash

DUMP_TEMPS_SCRIPT=${HOME}/bin/automine/amdgpu/show_temperatures.sh

while `killall -CHLD ethminer >/dev/null 2>&1`
do
    sudo $DUMP_TEMPS_SCRIPT > /tmp/gputemp.last ; sleep 2;
done;

# Add a loop to keep running the script for a minute or so after this condition
# is no longer met, avoid leaving fans at unnecessarily high speeds. Also now
# kills off our screen session if we kill ethminer.
kill -TERM `screen -list | grep ethminer | cut -d \. -f 1 | awk {'print $1'}` >/dev/null 2>&1
for ((i=0; i<30; i++))
do
    sudo $DUMP_TEMPS_SCRIPT > /tmp/gputemp.last ; sleep 2;
done


