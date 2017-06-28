#!/bin/bash
# Amends /etc/rc.local to launch the mining screen session.

source rsync_scripts.sh
ssh -t $SSH_USER sudo \$HOME/bin/automine/common/amend_rc_local.sh

echo '###########################################################################'
echo '# Remember to set up auto-login as described in'
echo '# http://www.ubuntugeek.com/how-to-enable-automatic-login-in-ubutnu.html'
echo '###########################################################################'



