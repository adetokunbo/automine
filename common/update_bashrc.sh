#!/bin/bash

AUTOMINE_RC=bin/automine/common/dot_bashrc

grep -q $AUTOMINE_RC $HOME/.bashrc || printf "\n\n[ -f ~/$AUTOMINE_RC ] && source ~/${AUTOMINE_RC}\n" >> ~/.bashrc
