#!/bin/bash
# Apply the configured overclocks
#
# It's also possible to control whether the overclocks are persistent:
#
# re-applys the overclocks automatically on unschedule machine restarts
#
# $ ./apply_overclocks.sh persist
#
# Removes persistence - if the overclocks are being applied automatically on
# unscheduled machine restarts this is stopped.
#
# $ ./apply_overclocks transient


apply_overclocks() {
    local persist=${1:-''}
    local trigger=~/.automine/var/triggers/overclock_on_restart.txt
    if [[ $persist == 'persist' ]]
    then
        touch $trigger
    fi
    if [[ $persist == 'transient' && -f $trigger ]]
    then
        rm -v $trigger
    fi
    mkdir -p /tmp/automine && cp -v ~/.automine/automine_config.json /tmp/automine
}

apply_overclocks "$@"
