#!/bin/bash

AUTOMINE_RC=bin/automine/common/dot_bashrc

add_rig_type() {
    printf "\n\nexport RIG_TYPE=${RIG_TYPE}" >> ~/.bashrc
}

update_rig_type() {
    sed --in-place='' -e s/export RIG_TYPE=.*/export RIG_TYPE=$RIG_TYPE/ ~/.bashrc
}

grep -q 'export RIG_TYPE' $HOME/.bashrc && update_rig_type || add_rig_type 
grep -q $AUTOMINE_RC $HOME/.bashrc || printf "\n\n[ -f ~/$AUTOMINE_RC ] && source ~/${AUTOMINE_RC}\n" >> ~/.bashrc
