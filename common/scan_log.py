#!/usr/bin/env python
"""A module that scans standard input for errors.

The log substrings to test the input for are configured in by a json file that
maps them to the path of the trigger file to be updated when they are detected

"""

from __future__ import print_function

from datetime import datetime, timedelta
import codecs
import json
import os
import random
import sys
import traceback


def _sibling_path(name):
    """Compute path of file relative to this module."""
    here = os.path.dirname(os.path.join(os.getcwd(), __file__))
    return os.path.normpath(os.path.join(here, name))


_CFG_MESSAGE = u"scan_log: config: {} == {}"


def read_cfg(cfg_path):
    """Load the error cfg"""
    try:
        fallback_pool = os.environ['FALLBACK_POOL']
        automine_alert_dir = os.environ['AUTOMINE_ALERT_DIR']
        _print(_CFG_MESSAGE.format('AUTOMINE_ALERT_DIR', automine_alert_dir))
        _print(_CFG_MESSAGE.format('FALLBACK_POOL', fallback_pool))
        raw_dict = json.load(open(cfg_path))
        cfg_dict = {}
        for key, value in iter(raw_dict.items()):
            new_key = key.replace("${FALLBACK_POOL}", fallback_pool)
            new_value = value.replace("${AUTOMINE_ALERT_DIR}",
                                      automine_alert_dir)
            cfg_dict[new_key] = new_value
        return cfg_dict
    except KeyError as err:
        raise ValueError(u'scan_log: Environment lacked {}'.format(err))


def _print(some_text):
    with open("/tmp/scan_log.out", "a") as out:
        print(some_text.encode('utf8'), file=out)


_MAX_COUNT = 2
_WAIT_FOR_A_BIT = timedelta(0, 30)  # don't trigger on any early logs
_PRINT_PERIOD = 1000


def perform_scan(src, error_cfg):
    """Scan lines of input for the configured errors"""
    start = datetime.utcnow()
    count = 0
    for subst, trigger_path in iter(error_cfg.items()):
        _print(u"scan_log: config: {} <- {}".format(trigger_path, subst))

    while True:  # does not exit until the input stream sends EOF
        a_line = src.readline()
        if not a_line:  # EOF; scan until input ends
            break

        # confirm the scan is working ok by:
        #
        # 1. log the initial few scanned lines
        a_line = a_line.strip()
        if not a_line:
            continue
        if count < _MAX_COUNT:  # print something to indicate scan is running ok
            count += 1
            if count == _MAX_COUNT:
                _print(u"scan_log: scanned up to {} lines OK".format(count))
                _print(u"scan_log: last line was {}".format(a_line))

        # ...
        # 2. logging random scanned lines
        now = datetime.utcnow()
        if now.second % _PRINT_PERIOD == random.randint(0, _PRINT_PERIOD - 1):
            _print(u"scan_log: last line was {}".format(a_line))

        # scan for the configured trigger lines
        for subst, trigger_path in iter(error_cfg.items()):
            if a_line.find(subst) == -1:
                continue

            # The 0.00MH/s scan is special; only record a crash if this is in
            # the log after the first minute.
            since_start = now - start
            if subst.find('0.00MH/s') != -1 and since_start < _WAIT_FOR_A_BIT:
                continue

            timestamp = now.isoformat() + 'Z'
            with open(trigger_path, 'a') as out:
                print(timestamp, file=out)
            _print(u"scan_log: trigger found: {}".format(a_line))
            _print(u"scan_log: done, restart triggered;  added {} at {}".
                   format(trigger_path, timestamp))


def main():
    """The command line entry point """
    cfg_path = _sibling_path('scan_log.json')
    if not os.path.exists(cfg_path):
        _print("No scan_log.json at {}, exiting".format(cfg_path))
        return 1
    try:
        reader = codecs.getreader('utf8')
        perform_scan(reader(sys.stdin), read_cfg(cfg_path))
        return 0
    except Exception as err:  # pylint: disable=broad-except
        _print(str(err))
        _print(traceback.format_exc())
        return 1


if __name__ == '__main__':
    sys.exit(main())
