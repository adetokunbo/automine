#!/usr/bin/env python
"""A module that execute commands to confirm the health of the gpus

Whenever a gpu is unhealthy, a trigger file in AUTOMINE_ALERT_DIR is updated.

Prequisites: the nvidia-smi tool should be installed

"""

from __future__ import print_function

from datetime import datetime
import os
import re
import subprocess
import sys
import traceback

_SHOW_GPUS_CMD = "nvidia-smi --query-gpu=index,clocks.sm,power.draw --format=csv,noheader"
_A_BAD_WAY = "[Unknown Error]"
_A_REALLY_BAD_WAY_RX = re.compile(
    r"[0-9a-fA-F]{4}:([0-9a-fA-F]{2}):[0-9a-fA-F]{2}\.[0-9a-fA-F]: GPU is lost",
    re.M)


def _print(some_text):
    with open("/tmp/gpu_health_log.out", "a") as out:
        print(some_text.encode('utf8'), file=out)


def perform_status_check():
    """Perform the status check."""
    try:
        out_dir = os.environ['AUTOMINE_ALERT_DIR']
        out_path = os.path.join(out_dir, 'failed_gpus.txt')
        show_gpus = subprocess.check_output(_SHOW_GPUS_CMD.split())

        # check if the output indicates that a GPU is 'lost'
        really_bad = _A_REALLY_BAD_WAY_RX.search(show_gpus)
        if really_bad:
            index = int(really_bad.group(1), 16)
            _mark_bad_gpu(out_path, index)
            return

        # read through the output lines to see if an individual GPU looks bad
        gpu_states = [l.split(', ') for l in show_gpus.splitlines()]
        for index, gpu_clock, power_draw in gpu_states:
            if gpu_clock != _A_BAD_WAY and power_draw != _A_BAD_WAY:
                continue
            _mark_bad_gpu(out_path, index)
    except KeyError as err:
        raise ValueError(u'gpu_health: Environment lacked {}'.format(err))


def _mark_bad_gpu(trigger_path, gpu_index):
    """Leave a record that a GPU was bad."""
    now = datetime.utcnow().isoformat() + 'Z'
    with open(trigger_path, 'a') as out:
        print('gpu{:02d}:{}'.format(int(gpu_index), now), file=out)
        _print(u"gpu_health: wrote to {} at {}".format(trigger_path, now))


def main():
    """The comamnd line entry point """
    try:
        perform_status_check()
        return 0
    except ValueError as err:
        _print(err)
        return 1
    except Exception:  # pylint: disable=broad-except
        _print(traceback.format_exc())
        return 1


if __name__ == '__main__':
    sys.exit(main())
