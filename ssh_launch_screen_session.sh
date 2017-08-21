#!/bin/bash

source rsync_scripts.sh
ssh -t $SSH_USER -p${SSH_PORT} \~/bin/automine/$RIG_TYPE/launch_screen_session.sh
