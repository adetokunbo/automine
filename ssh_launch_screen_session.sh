#!/bin/bash

source rsync_scripts.sh
ssh -t $SSH_USER \~/bin/automine/$RIG_TYPE/launch_screen_session.sh
