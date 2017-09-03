#!/usr/bin/env python
"""A module that execute commands to confirm the health of the gpus

Whenever a gpu is unhealthy, a trigger file in AUTOMINE_ALERT_DIR is updated.

Prequisites: the nvidia-smi tool should be installed

"""

from __future__ import print_function

from datetime import datetime
import json
import logging
from logging.config import dictConfig
import os
import re
import subprocess
import sys

_SHOW_GPUS_CMD = "nvidia-smi --query-gpu=index,clocks.sm,power.draw --format=csv,noheader"
_A_BAD_WAY = "[Unknown Error]"
_A_REALLY_BAD_WAY_RX = re.compile(
    r"[0-9a-fA-F]{4}:([0-9a-fA-F]{2}):[0-9a-fA-F]{2}\.[0-9a-fA-F]: GPU is lost",
    re.M)


def _log_name():
    """The name to use for logging"""
    return os.path.splitext(os.path.basename(__file__))[0]


_LOG = logging.getLogger(_log_name())


def _info(some_text):
    _LOG.info(some_text)


_UNKNOWN_GPU = 49


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
    except subprocess.CalledProcessError:
        _mark_bad_gpu(out_path, _UNKNOWN_GPU)
    except KeyError as err:
        raise ValueError(u'gpu_health: Environment lacked {}'.format(err))


def _mark_bad_gpu(trigger_path, gpu_index):
    """Leave a record that a GPU was bad."""
    now = datetime.utcnow().isoformat() + 'Z'
    with open(trigger_path, 'a') as out:
        print('gpu{:02d}:{}'.format(int(gpu_index), now), file=out)
        _info(u"wrote to {} at {}".format(trigger_path, now))


def _configure_logger():
    """Configures logging

    logging_config.json should have been placed in the directory AUTOMINE_LOG_DIR,
    to which this process must have read and write access

    """
    try:
        log_dir = os.environ['AUTOMINE_LOG_DIR']
        log_name = _log_name()
        cfg_path = os.path.join(log_dir, 'logging_config.json')
        with open(cfg_path) as src:
            cfg = json.load(src, 'utf8')
            handlers = cfg.get('handlers')
            for handler in iter(handlers.itervalues()):
                filename = handler.get('filename')
                if filename:
                    filename = filename.replace('{{AUTOMINE_LOG_DIR}}',
                                                log_dir)
                    filename = filename.replace('{{__name__}}', log_name)
                    handler['filename'] = filename
            loggers = cfg.get('loggers')
            if '__name__' in loggers:
                loggers[log_name] = loggers.pop('__name__')
            dictConfig(cfg)
    except Exception as err:  # pylint: disable=broad-except
        logging.basicConfig()
        raise err


def main():
    """The command line entry point """
    try:
        _configure_logger()
        perform_status_check()
        return 0
    except Exception:  # pylint: disable=broad-except
        _LOG.error('could not perform overclock', exc_info=True)
        return 1


if __name__ == '__main__':
    sys.exit(main())
