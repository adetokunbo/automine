#/bin/bash
# Build the version of the ethminer for the rig's $RIG_TYPE.

REPO_DIR=$HOME/.automine/var/src
BIN_DIR=$HOME/bin

_ensure_repo_dir() {
    [[ -d $REPO_DIR ]] || mkdir -p $REPO_DIR
}

_ensure_bin_dir() {
    [[ -d $BIN_DIR ]] || mkdir -p $BIN_DIR
}

_ensure_cmake() {
    sudo apt -y update
    sudo apt -y install cmake
}

_ensure_environment() {
    _ensure_repo_dir
    _ensure_bin_dir
    _ensure_cmake
}

_pull_source() {
    cd $REPO_DIR && [[ -d ethminer ]] && rm -fR ethminer

    local branch_name=${ETHMINER_BRANCH:=''}
    local github_user=${ETHMINER_GITHUB:='ethereum-mining'}
    local branch_clause=''
    [[ -z $branch_name ]] || branch_clause="-b $branch_name"
    git clone --depth 1 $branch_clause https://github.com/$github_user/ethminer

    local commit=${ETHMINER_COMMIT:=''}
    [[ -z $commit ]] || {
        cd $REPO_DIR/ethminer && git reset --hard $commit
    }
}

_build() {
    cd $REPO_DIR/ethminer
    mkdir build
    cd build
    cmake .. -DETHASHCUDA=${ETHASHCUDA}
    cmake --build .
}

_install() {
    $BIN_DIR/automine_run minerctl stop || /bin/true
    cp -v $REPO_DIR/ethminer/build/ethminer/ethminer $BIN_DIR/ethminer
    $BIN_DIR/automine_run minerctl restart
}

_pull_source_then_build_and_install() {
    _pull_source
    _build
    _install
}

_add_symlinks() {
    local this_dir=$(dirname "${BASH_SOURCE[${#BASH_SOURCE[@]} - 1]}")
    local rig_dir=$(dirname $this_dir)/$RIG_TYPE
    [ -f ${rig_dir}/add_symlinks.sh ] && source ${rig_dir}/add_symlinks.sh
}

# update .bashrc with functions that encode typical usage scenarios
_update_bashrc() {
    $BIN_DIR/automine_run update_bashrc
}

_post_install() {
    _add_symlinks
    _update_bashrc
}

set -e
set -u
_ensure_environment
_pull_source_then_build_and_install
_post_install
