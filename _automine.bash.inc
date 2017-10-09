#!/bin/bash
# Installs a function for invoking the automine scripts.

# Find the completion list of the names of top-level automine scripts that don't
# begin with '_' (as those are internal) that match the filter
__automine_find_completions() {
    local filter=${1:-''}
    local this_dir=$(dirname "${BASH_SOURCE[${#BASH_SOURCE[@]} - 1]}")
    local scripts=$(PATH=$this_dir:$PATH compgen -c | grep '^automine_')
    for a_script in $scripts
    do
        local remove_prefix=${a_script##automine_}
        local remove_ext=${remove_prefix%*.sh}
        [[ -z $filter || $remove_ext =~ $filter ]] && echo $remove_ext
    done
}

# Find the completion list of configured rigs that match the filter
__automine_find_configured_hosts() {
    local filter=${1:-''}
    local cfg_dir=${AUTOMINE_CFG_DIR:=${HOME}/.automine/rig_config}
    local cfgs=$(ls $cfg_dir/*.automine_config.json)
    for a_cfg in $cfgs
    do
        local remove_prefix=${a_cfg##"${cfg_dir}/"}
        local remove_ext=${remove_prefix%*.automine_config.json}
        [[ -z $filter || $remove_ext =~ $filter ]] && echo $remove_ext
    done
}

# Implement the bash completion protocol using the __automine_find_* functions
__automine_complete() {
    local command=$1
    local cur_word=$2
    local last_word=$3
    if __automine_is_configured_host $last_word
    then
        local cur=${COMP_WORDS[COMP_CWORD]}
        COMPREPLY=($(echo $(__automine_find_completions $cur)))
    fi
    if [[ $last_word == "automine" ]]
    then
        local cur=${COMP_WORDS[COMP_CWORD]}
        COMPREPLY=($(echo $(__automine_find_completions $cur)))
        COMPREPLY+=('-a')
    fi
    if [[ $last_word == "remote_run" ]]
    then
        local cur=${COMP_WORDS[COMP_CWORD]}
        COMPREPLY=($(echo $(__automine_find_all_remote_subcommands $cur)))
    fi
    if [[ $last_word == "-a" ]]
    then
        local cur=${COMP_WORDS[COMP_CWORD]}
        COMPREPLY=($(echo $(__automine_find_configured_hosts $cur)))
    fi
}

# Find the completion list of remote_run subcommands that match the filter
__automine_find_all_remote_subcommands() {
    local filter=${1:-''}
    local rig_type_dir=${RIG_TYPE:-''}
    [[ -n $rig_type_dir ]] && __automine_list_commands ${rig_type_dir}/*.sh $filter
    __automine_list_commands 'common/*.sh' $filter
    __automine_list_commands 'common/systemd/*.sh' $filter
}

# List all automine scripts matching command_glob
__automine_list_commands() {
    local command_glob=$1
    local filter=${2:-''}
    local this_dir=$(dirname "${BASH_SOURCE[${#BASH_SOURCE[@]} - 1]}")
    for a_script in $(ls -1 $this_dir/${command_glob})
    do
        local base=${a_script##*/}
        local short_base=${base%.*}
        [[ -z $filter || $short_base =~ $filter ]] && echo $short_base
    done
}

# Determine if a command is a top-level automine command
__automine_is_command() {
    local command=${1:-''}
    local all_commands=($(echo $(__automine_find_completions)))
    local found=1
    for name in "${all_commands[@]}"; do
        [[ $name == "$command" ]] && {
            found=0
            break
        }
    done
    return $found
}

# Determine if a host is one of the configured hosts
__automine_is_configured_host() {
    local host=${1:-''}
    local all_hosts=($(echo $(__automine_find_configured_hosts)))
    local found=1
    for name in "${all_hosts[@]}"; do
        [[ $name == "$host" ]] && {
            found=0
            break
        }
    done
    return $found
}

# Parse a value for RIG_HOST from the -a option
__automine_maybe_parse_rig_host_option() {
    OPTIND=1
    local options_found=0
    local opt
    while getopts ":a:" opt;
    do
        options_found=1
        case $opt in
            a)
                if __automine_is_command $OPTARG
                then
                    echo "Option -a requires a rig hostname argument." >&2
                    return 1
                fi
                export RIG_HOST=$OPTARG
                ;;
            \?)
                echo "Invalid option: -$OPTARG" >&2
                return 1
                ;;
            :)
                echo "Option -$OPTARG requires an argument." >&2
                return 1
                ;;
        esac
    done
    return 0
}

# The entry-point function for running automine commands
automine() {
    if  __automine_maybe_parse_rig_host_option "$@"
    then
        # update the args if an option was passed in ..maybe_parse_rig_host_option
        shift $((OPTIND-1))

        # determine the command to run and make sure its passed the correct
        # sub-command
        local command=$1
        if [ "$#" -gt 0 ];
        then
            shift
        fi

        # run the command if it exists, otherwise report an error
        if __automine_is_command $command
        then
            local this_dir=$(dirname "${BASH_SOURCE[${#BASH_SOURCE[@]} - 1]}")
            local cmd_script=${this_dir}/automine_${command}.sh
            PATH=$this_dir:$PATH $cmd_script "$@"
        else
            local all_commands=($(echo $(__automine_find_completions)))
            echo "Unknown automine sub-command: '$command'"
            echo "The available sub-commands are:"
            echo "${all_commands[@]}"
        fi
    fi
}

# register automine for bash completion
complete -o nospace -F __automine_complete automine
