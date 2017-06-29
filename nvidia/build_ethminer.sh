#/bin/bash

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
    cd $REPO_DIR/ethminer
    mkdir build
    cd build
    cmake .. -DETHASHCUDA=ON
    cmake --build .
}

cp_to_bin() {
    cp -v $REPO_DIR/ethminer/build/ethminer/ethminer $BIN_DIR
}

add_symlinks() {
    ln -sf $BIN_DIR/automine/nvidia/launch_screen_session.sh $BIN_DIR/mine_in_a_screen
}

set -e
ensure_repo_dir
ensure_bin_dir
pull_fresh_ethminer
build_ethminer
cp_to_bin
add_symlinks



