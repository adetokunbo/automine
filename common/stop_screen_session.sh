#!/bin/bash


# Terminate any existing ethminer or screens
killall -TERM ethminer >/dev/null 2>&1
kill -TERM `screen -list | grep ethminer | cut -d \. -f 1 | awk {'print $1'}` >/dev/null 2>&1

