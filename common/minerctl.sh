#!/bin/bash
# An alias for the systemctl command that controls the automine service
#
# This one-liner is a script rather than a function as that simplifies use via
# SSH

systemctl --user ${1:-restart} automine
