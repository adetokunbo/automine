#!/usr/bin/env python
"""A module that execute commands to confirm the health of the gpus

Whenever a gpu is unhealthy, a trigger file in AUTOMINE_ALERT_DIR is updated.

Prequisites: the nvidia-smi tool should be installed

"""

from __future__ import print_function

from datetime import datetime
import os
import subprocess
import sys
import traceback


_SHOW_GPUS_CMD = "nvidia-smi --query-gpu=index,clocks.sm,power.draw --format=csv,noheader"
_A_BAD_WAY = "[Unknown Error]"


def _print(some_text):
    with open("/tmp/gpu_health_log.out", "a") as out:
        print(some_text.encode('utf8'), file=out)


def perform_status_check():
    """Perform the status check."""
    try:
        trigger_dir = os.environ['AUTOMINE_ALERT_DIR']
        gpu_state = subprocess.check_output(_SHOW_GPUS_CMD.split())
        for (index, gpu_clock, power_draw) in [l.split(', ') for l in gpu_state.splitlines()]:
            if gpu_clock == _A_BAD_WAY or power_draw == _A_BAD_WAY:
                # write a timestamp to the trigger file
                now = datetime.utcnow()
                timestamp = now.isoformat() + 'Z'
                trigger_path = os.path.join(trigger_dir, 'gpu{:02d}'.format(int(index)))
                with open(trigger_path, 'a') as out:
                    print(timestamp, file=out)
                    _print(u"gpu_health: done, wrote to {} at {}".format(trigger_path, timestamp))

    except KeyError as err:
        raise ValueError(u'gpu_health: Environment did not specify {}'.format(err))


def main():
    """The comamnd line entry point """
    try:
        perform_status_check()
    except Exception as err:  # pylint: disable=broad-except
        exc_type, exc_value, exc_traceback = sys.exc_info()
        _print(str(err))
        _print(repr(traceback.format_exception(exc_type, exc_value,
                                               exc_traceback)))
        sys.exit(1)

if __name__ == '__main__':
    main()
