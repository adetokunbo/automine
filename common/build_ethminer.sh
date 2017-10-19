#/bin/bash
# Build the version of the ethminer for the rig's $RIG_TYPE.

this_dir() {
    local script_path="${BASH_SOURCE[0]}"
    if ([ -h "${script_path}" ])
    then
        while([ -h "${script_path}" ])
        do
            script_path=`readlink "${script_path}"`;
        done
    fi
    pushd . > /dev/null
    cd $(dirname ${script_path}) > /dev/null
    script_path=$(pwd);
    popd  > /dev/null
    echo $script_path
}

SCRIPT_DIR=$(this_dir)
REPO_DIR=$HOME/.automine/var/src
BIN_DIR=$HOME/bin

ensure_repo_dir() {
    [[ -d $REPO_DIR ]] || mkdir -p $REPO_DIR
}

ensure_bin_dir() {
    [[ -d $BIN_DIR ]] || mkdir -p $BIN_DIR
}

pull_fresh_ethminer() {
    cd $REPO_DIR && [[ -d ethminer ]] && rm -fR ethminer

    local branch_name=${ETHMINER_BRANCH:=''}
    local github_user=${ETHMINER_GITHUB:='ethereum-mining'}
    local branch_clause=''
    [[ -z $branch_name ]] || branch_clause="-b $branch_name"
    git clone $branch_clause https://github.com/$github_user/ethminer

    local commit=${ETHMINER_COMMIT:=''}
    [[ -z $commit ]] || {
        cd $REPO_DIR/ethminer && git reset --hard $commit
    }
}

build_ethminer() {
    cd $REPO_DIR/ethminer
    mkdir build
    cd build
    cmake .. -DETHASHCUDA=${ETHASHCUDA}
    cmake --build .
}

cp_to_bin() {
    $BIN_DIR/automine_run minerctl stop || /bin/true
    cp -v $REPO_DIR/ethminer/build/ethminer/ethminer $BIN_DIR/ethminer
    $BIN_DIR/automine_run minerctl restart
}

add_symlinks() {
    local rig_dir=$(dirname $SCRIPT_DIR)/$RIG_TYPE
    [ -f ${rig_dir}/add_symlinks.sh ] && source ${rig_dir}/add_symlinks.sh
}

set -e
set -u
ensure_repo_dir
ensure_bin_dir
pull_fresh_ethminer
build_ethminer
cp_to_bin
add_symlinks

# update .bashrc with functions that encode typical usage scenarios
source $SCRIPT_DIR/update_bashrc.sh
