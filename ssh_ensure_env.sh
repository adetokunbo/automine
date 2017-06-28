#!/bin/bash

RIG_IP=${RIG_IP:=192.168.11.11}
source cfg/${RIG_IP}.sh
SSH_USER=${RIG_USER}@${RIG_IP}
DOWNLOAD_DIR=${HOME}/Downloads/${RIG_TYPE}
