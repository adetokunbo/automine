#!/usr/bin/env python3
"""A module that scans standard input for errors.

The substrings that the logfile lines are tested for are configured by a json
file that maps each test to the path of a trigger file to be updated when the
test succeeds.

"""

from datetime import datetime, timedelta
import json
from logging.config import dictConfig
import logging
import os
import random
import sys


def _log_name():
    """The name to use for logging"""
    return os.path.splitext(os.path.basename(__file__))[0]


_LOG = logging.getLogger(_log_name())


def _info(some_text):
    _LOG.info(some_text)


def _sibling_path(name):
    """Compute path of file relative to this module."""
    here = os.path.dirname(os.path.join(os.getcwd(), __file__))
    return os.path.normpath(os.path.join(here, name))


def _as_timestamp(now):
    """formats now as string timestamp"""
    return now.isoformat() + 'Z'


_CFG_MESSAGE = u"config: {} == {}"


def read_cfg(cfg_path):
    """Load the scan cfg"""
    try:
        fallback_pool = os.environ['FALLBACK_POOL']
        fallback_pool_host = fallback_pool.split(':')[0]
        automine_alert_dir = os.environ['AUTOMINE_ALERT_DIR']
        _info(_CFG_MESSAGE.format('AUTOMINE_ALERT_DIR', automine_alert_dir))
        _info(_CFG_MESSAGE.format('FALLBACK_POOL', fallback_pool_host))
        raw_dict = json.load(open(cfg_path))
        cfg_dict = {}
        for key, value in iter(list(raw_dict.items())):
            new_key = key.replace("${FALLBACK_POOL}", fallback_pool_host)
            new_value = value.replace("${AUTOMINE_ALERT_DIR}",
                                      automine_alert_dir)
            cfg_dict[new_key] = new_value
        return cfg_dict
    except KeyError as err:
        raise ValueError(u'Environment lacked {}'.format(err))


_TRACKER_PERIOD = timedelta(0, 120, 0)  # make a tracker record every 2 mins
_PRINT_PERIOD = 1000


def _update_log_tracker(now, latest, last_scanned):
    """Indicate that the log scanner is making progress"""
    if now.second % _PRINT_PERIOD == random.randint(0, _PRINT_PERIOD - 1):
        _info(u"last line was {}".format(last_scanned))
    tracker_path = _tracker_path()
    if (now - latest) <= _TRACKER_PERIOD:
        return latest
    with open(tracker_path, 'w') as out:
        print(_as_timestamp(now), file=out)
        return now


def _tracker_path():
    """Determine the tracker path"""
    try:
        automine_alert_dir = os.environ['AUTOMINE_ALERT_DIR']
        return os.path.join(automine_alert_dir, 'scan_log_tracker.txt')
    except KeyError as err:
        raise ValueError(u'Environment lacked {}'.format(err))


def _print_cfg(scan_cfg):
    """Initialize the log of the scan log."""
    _info(u"tracker_path: {}".format(_tracker_path()))
    for subst, trigger_path in iter(list(scan_cfg.items())):
        _info(u"config: {} <- {}".format(trigger_path, subst))


_MAX_COUNT = 2
_TOO_MANY_ZEROS = 10
_WAIT_FOR_A_BIT = timedelta(0, 30)  # don't trigger on any early logs


def perform_scan(src, scan_cfg):
    """Scan lines of input for the configured errors"""
    _print_cfg(scan_cfg)
    start = datetime.utcnow()
    latest_log = start - _TRACKER_PERIOD
    count = 0
    consecutive_zeroes = 0
    while True:  # does not exit until the input stream sends EOF
        a_line = src.readline()
        if not a_line:  # EOF; scan until input ends
            break
        a_line = a_line.strip()
        if not a_line:  # ignore lines that are empty
            continue

        # confirm the scan is working ok by:
        #
        # 1. log the initial few scanned lines
        if count < _MAX_COUNT:  # print something to indicate scan is running ok
            count += 1
            if count == _MAX_COUNT:
                _info(u"scanned up to {} lines OK".format(count))
                _info(u"last line was {}".format(a_line))

        # ...
        # 2. logging random scanned lines; update  log tracker file
        now = datetime.utcnow()
        latest_log = _update_log_tracker(now, latest_log, a_line)

        # scan for the configured trigger lines
        for subst, trigger_path in iter(list(scan_cfg.items())):
            if a_line.find(subst) == -1:
                consecutive_zeroes = 0
                continue

            # The 0.00MH/s scan is special; only record a crash if this is in
            # the log after the first minute, and if there have been a number
            # of matching lines in a row
            since_start = now - start
            zeroed = subst.find('0.00MH/s') != -1
            if zeroed and since_start < _WAIT_FOR_A_BIT:
                continue

            if zeroed and consecutive_zeroes < _TOO_MANY_ZEROS:
                consecutive_zeroes += 1
                continue

            with open(trigger_path, 'a') as out:
                print(_as_timestamp(now), file=out)
            _info(u"trigger found: {}".format(a_line))
            _info(u"done, restart triggered;  added {} at {}".format(
                trigger_path, _as_timestamp(now)))


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
            cfg = json.load(src)
            handlers = cfg.get('handlers')
            for handler in iter(handlers.values()):
                filename = handler.get('filename')
                if filename:
                    filename = filename.replace('{{AUTOMINE_LOG_DIR}}',
                                                log_dir)
                    filename = filename.replace('{{__name__}}', log_name)
                    handler['filename'] = filename
            loggers = cfg.get('loggers')
            if '__name__' in loggers:
                loggers[log_name] = loggers.pop('__name__')

                # add logging to the console if env var is set
                log_to_console = 'AUTOMINE_LOG_TO_CONSOLE' in os.environ
                if log_to_console and 'console' in handlers:
                    logger_handlers = loggers[log_name].get('handlers')
                    if logger_handlers:
                        logger_handlers.append('console')

            dictConfig(cfg)
    except Exception as err:  # pylint: disable=broad-except
        logging.basicConfig()
        raise err


def main():
    """The command line entry point """
    try:
        _configure_logger()
        cfg_path = _sibling_path('scan_log.json')
        if not os.path.exists(cfg_path):
            _info("No scan_log.json at {}, exiting".format(cfg_path))
            return 1
        perform_scan(sys.stdin, read_cfg(cfg_path))
        return 0
    except Exception:  # pylint: disable=broad-except
        _LOG.error('could not scan the log output', exc_info=True)
        return 1


if __name__ == '__main__':
    sys.exit(main())
