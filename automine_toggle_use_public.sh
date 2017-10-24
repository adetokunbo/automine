#!/bin/bash
# Toggle the USE_PUBLIC sentinel file.
#
# If ~/.automine/.use_public exists, the scripts behave as if the USE_PUBLIC
# environment variable is on.

toggle_use_public() {
    local sentinel=~/.automine/.use_public
    if [[ -f $sentinel ]]
    then
        rm $sentinel
        echo "Toggled USE_PUBLIC: OFF"
    else
        touch $sentinel
        echo "Toggled USE_PUBLIC: ON"
    fi
}

toggle_use_public
