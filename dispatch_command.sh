#!/bin/bash

_abort() {
    local message=${1:-"no reason was given"}
    echo "aborting: $message"
    exit 1
}

_try_command() {
    local command_dir=$1
    shift
    local command_name=$1
    shift
    for a_script in $(ls -1 ${AUTOMINE_SCRIPT_DIR:-''}${command_dir}/*.{py,sh})
    do
        local base=${a_script##*/}
        local short_base=${base%.*}
        if [[ $short_base == $command_name ]]
        then
            $a_script "$@"
            return 0
        fi
    done
    return 1
}

dispatch_command() {
    local command_name=${1:-''}
    [[ -z $command_name ]] && _abort "no automine command specified"
    shift

    # export any configured/derived/defaulted environment variables that might
    # affect automine commands
    eval $($HOME/bin/automine_show_config shell_exports)
    [ ${RIG_TYPE:-''} == 'nvidia' ] && export ETHASHCUDA=ON || export ETHASHCUDA=OFF
    export AUTOMINE_SCRIPT_DIR=${AUTOMINE_SCRIPT_DIR:=$HOME/bin/automine/}
    export AUTOMINE_RUNTIME_DIR=${AUTOMINE_RUNTIME_DIR:=$HOME/.automine/var}

    # dispatch the command, i,e determine its script location and run it if found
    local rig_type_dir=${RIG_TYPE:-''}
    [[ -n $rig_type_dir ]] \
        && _try_command $rig_type_dir $command_name "$@" \
        && exit $? || true
    _try_command 'common' $command_name "$@" \
        || _try_command 'common/systemd' $command_name "$@" \
        || {
            _abort "could not find a script for automine command '$command_name'"
        }
}

set -e
set -u
dispatch_command "$@"
