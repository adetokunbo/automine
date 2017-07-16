#!/usr/bin/env python
"""A module that scans standard input for errors.

The log substrings to test the input for are configured in by a json file that
maps them to the path of the trigger file to be updated when they are detected

"""

from __future__ import print_function

from datetime import datetime, timedelta
import json
import os
import sys
import traceback


def _sibling_path(name):
    """Compute path of file relative to this module."""
    here = os.path.dirname(os.path.join(os.getcwd(), __file__))
    return os.path.normpath(os.path.join(here, name))


def read_cfg(cfg_path):
    """Load the error cfg"""
    try:
        fallback_pool = os.environ['FALLBACK_POOL']
        automine_alert_dir = os.environ['AUTOMINE_ALERT_DIR']
        raw_dict = json.load(open(cfg_path))
        cfg_dict = {}
        for key, value in iter(raw_dict.items()):
            new_key = key.replace("${FALLBACK_POOL}", fallback_pool)
            new_value = value.replace("${AUTOMINE_ALERT_DIR}", automine_alert_dir)
            cfg_dict[new_key] = new_value
        return cfg_dict
    except KeyError as err:
        raise ValueError('scan_log: Environment did not specify {}'.format(err))


def _print(some_text):
    with open("/tmp/scan_log.out", "a") as fh:
        print(some_text, file=fh)


_MAX_COUNT = 2
_MIN_LOG_TIME = timedelta(0, 60)  # don't log some errors for the first minute


def perform_scan(src, error_cfg):
    """Scan lines of input for the configured errors"""
    start = datetime.now()
    count = 0
    while True:
        a_line = src.readline()
        if not a_line:  # EOF
            break
        if count < _MAX_COUNT:  # print something to indicate scan is running ok
            count += 1
            if count == _MAX_COUNT:
                _print("scan_log: scanned up to {} lines OK".format(count))

        # scan for the configured lines, halting the scan once an error occurs
        now = datetime.now()
        for subst, trigger_path in iter(error_cfg.items()):
            if a_line.find(subst) == -1:
                continue

            # The 0.00MH/s scan is special; only record a crash if this is in
            # the log after the first minute.
            if subst.find('0.00MH/s') != -1 and (now - start) < _MIN_LOG_TIME:
                continue
            open(trigger_path, 'a').write(now.strftime('%Y/%m/%D::%H:%M:%S\n'))
            _print("scan_log: done, wrote to {} at {}".format(trigger_path, now))
            return  # exit once any error occurs

def main():
    """The comamnd line entry point """
    cfg_path = _sibling_path('scan_log.json')
    if not os.path.exists(cfg_path):
        _print("No scan_log.json at {}, exiting".format(cfg_path))
        sys.exit(1)
    try:
        perform_scan(sys.stdin, read_cfg(cfg_path))
        sys.exit(1)  # indicate that the src program errored
    except ValueError as err:
        _print(str(err))
        sys.exit(1)


if __name__ == '__main__':
    main()
