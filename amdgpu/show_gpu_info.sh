#/bin/bash
ls /sys/kernel/debug/dri/?/amdgpu_pm_info | while read f; do cat $f | grep \:; echo ""; done;
