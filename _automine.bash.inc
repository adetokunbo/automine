#!/bin/bash
# Installs a function for invoking the automine scripts.

# Add as completions the names of top-level automine scripts that don't begin
# with '_' (as those are internal) that match the keyword
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

# Implement the bash completion protocol using the __automine_find_* functions
__automine_complete() {
    local command=$1
    local cur_word=$2
    local last_word=$3
    if [[ $last_word == "automine" ]]
    then
        local cur=${COMP_WORDS[COMP_CWORD]}
        COMPREPLY=($(echo $(__automine_find_completions $cur)))

    fi
    if [[ $last_word == "remote_run" ]]
    then
        local cur=${COMP_WORDS[COMP_CWORD]}
        COMPREPLY=($(echo $(__automine_find_all_remote_subcommands $cur)))
    fi
}

__automine_find_all_remote_subcommands() {
    local filter=${1:-''}
    local rig_type_dir=${RIG_TYPE:-''}
    [[ -n $rig_type_dir ]] && __automine_list_commands ${rig_type_dir}/*.sh $filter
    __automine_list_commands 'common/*.sh' $filter
    __automine_list_commands 'common/systemd/*.sh' $filter
}

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

automine() {
    local this_dir=$(dirname "${BASH_SOURCE[${#BASH_SOURCE[@]} - 1]}")
    all_commands=($(echo $(__automine_find_completions)))
    local command=$1
    if [ "$#" -gt 0 ];
    then
        shift
    fi

    local found=0
    
    for name in "${all_commands[@]}"; do
        [[ $name == "$command" ]] && {
            local cmd_script=${this_dir}/automine_${command}.sh
            PATH=$this_dir:$PATH $cmd_script "$@"
            found=1
            break
        }
    done

    if (( found == 0 ))
    then
        echo "Unknown automine sub-command: '$command'"
        echo "The available sub-commands are:"
        echo "${all_commands[@]}"
    fi
}

complete -o nospace -F __automine_complete automine
