#/bin/bash

REPO_DIR=$HOME/var/repos
BIN_DIR=$HOME/bin

ensure_repo_dir() {
    [[ -d $REPO_DIR ]] || mkdir -p $REPO_DIR
}

ensure_bin_dir() {
    [[ -d $BIN_DIR ]] || mkdir -p $BIN_DIR
}

pull_fresh_cpp_ethereum() {
    cd $REPO_DIR
    [[ -d cpp-ethereum ]] && rm -fR cpp-ethereum
    git clone https://github.com/Genoil/cpp-ethereum/
}

build_cpp_ethereum() {
    cd $REPO_DIR/cpp-ethereum
    mkdir build
    cd build
    cmake -DBUNDLE=miner ..
    make -j2
}

cp_to_bin() {
    cp -v $REPO_DIR/cpp-ethereum/build/ethminer/ethminer $BIN_DIR
}

add_symlinks() {
    ln -sf $BIN_DIR/automine/amdgpu/control_gpus.sh $BIN_DIR/amdgpus
    ln -sf $BIN_DIR/automine/amdgpu/launch_screen_session.sh $BIN_DIR/mine_in_a_screen
}

set -e
ensure_repo_dir
ensure_bin_dir
pull_fresh_cpp_ethereum
build_cpp_ethereum
cp_to_bin
add_symlinks



