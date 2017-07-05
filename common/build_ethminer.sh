#/bin/bash

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
REPO_DIR=$HOME/var/repos
BIN_DIR=$HOME/bin

ensure_repo_dir() {
    [[ -d $REPO_DIR ]] || mkdir -p $REPO_DIR
}

ensure_bin_dir() {
    [[ -d $BIN_DIR ]] || mkdir -p $BIN_DIR
}

pull_fresh_ethminer() {
    cd $REPO_DIR
    [[ -d cpp-ethereum ]] && rm -fR cpp-ethereum
    [[ -d ethminer ]] && rm -fR ethminer
    git clone https://github.com/ethereum-mining/ethminer
}

build_ethminer() {
    set -u
    cd $REPO_DIR/ethminer
    mkdir build
    cd build
    cmake .. -DETHASHCUDA=${ETHASHCUDA}
    cmake --build .
    set +u
}

cp_to_bin() {
    cp -v $REPO_DIR/ethminer/build/ethminer/ethminer $BIN_DIR
}

add_symlinks() {
    set -u
    local rig_dir=$(dirname $SCRIPT_DIR)/$RIG_TYPE
    ln -sf ${rig_dir}/launch_screen_session.sh $BIN_DIR/mine_in_a_screen
    [ -f ${rig_dir}/add_symlinks.sh ] && source ${rig_dir}/add_symlinks.sh
    set +u
}

source $SCRIPT_DIR/install_ethminer_deps.sh
set -e
ensure_repo_dir
ensure_bin_dir
pull_fresh_ethminer
build_ethminer
cp_to_bin
add_symlinks

# update .bashrc with functions that encode typical usage scenarios
source $SCRIPT_DIR/update_bashrc.sh
