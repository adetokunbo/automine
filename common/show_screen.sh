#!/bin/bash
# Displays the screen session running the miner if it is present

show_screen() {
    local em_screen=$(screen -ls | grep ethminer | awk {'print $1'})
    [ -z ${em_screen} ] && echo "no ethminer screen available" || screen -D -R
}

show_screen
