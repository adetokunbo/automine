#!/bin/bash

DUMP_TEMPS_SCRIPT=${HOME}/bin/automine/amdgpu/show_temperatures.sh

# Assumes ethminer ignores the CHLD signal, but once it stops, killall will fail
while $(killall -s CHLD ethminer >/dev/null 2>&1)
do
    sudo $DUMP_TEMPS_SCRIPT > /tmp/gputemp.last ; sleep 2;
done;

# Keep running the script for a minute or so to avoid leaving fans at
# unnecessarily high speeds
for ((i=0; i<30; i++))
do
    sudo $DUMP_TEMPS_SCRIPT > /tmp/gputemp.last ; sleep 2;
done


