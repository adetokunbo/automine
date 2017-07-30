#!/usr/bin/env python
"""A module that checks if scan_log is continuing to run.

track_scan_log checks that the tracker file created by scan_log exists and has
been updated recently. If not, it updates a trigger file.

It is intended to be run via a timer task that gets activated whenever scan_log
is in use.

"""

from __future__ import print_function

from datetime import datetime, timedelta
import os
import sys
import time
import traceback


def _print(some_text):
    with open("/tmp/track_scan_log.out", "a") as out:
        print(some_text.encode('utf8'), file=out)


def _tracker_path():
    """Determine the tracker path"""
    return _alert_dir_path('scan_log_tracker.txt')


def _trigger_path():
    """Determine the trigger file path"""
    return _alert_dir_path('scan_log_is_stale.txt')


def _alert_dir_path(basename):
    """Determine path to the basename in the alert directory"""
    try:
        automine_alert_dir = os.environ['AUTOMINE_ALERT_DIR']
        return os.path.join(automine_alert_dir, basename)
    except KeyError as err:
        raise ValueError(u'scan_log: Environment lacked {}'.format(err))


_TRACKER_PERIOD = timedelta(0, 120, 0)


def _tracker_exists():
    """Check that tracker path exists, waiting _TIMEOUT if necessary"""
    now = datetime.utcnow()
    tracker = _tracker_path()
    if os.path.exists(tracker):
        _print("Found tracker {} at {}".format(tracker, now))
        return tracker

    time.sleep(_TRACKER_PERIOD.seconds * 2)
    result = os.path.exists(tracker)
    if result:
        _print("Found tracker {} at {}".format(tracker, now))
        return tracker
    else:
        _print("Did not find tracker {} at {}".format(tracker, now))
        return None


def _is_recent(tracker_path):
    with open(tracker_path, 'r') as _fd:
        timestamp = _fd.read().strip()
        last_logged = datetime.strptime(timestamp, "%Y-%m-%dT%H:%M:%S.%fZ")
        now = datetime.utcnow()
        if now - last_logged > _TRACKER_PERIOD:
            _print("Tracker timestamp was stale; {} at {}".format(last_logged,
                                                                  now))
            return False
        else:
            return True


def _add_trigger():
    """Leave a record that a GPU was bad."""
    trigger_path = _trigger_path()
    now = datetime.utcnow().isoformat() + 'Z'
    with open(trigger_path, 'a') as out:
        print(now, file=out)
        _print(u"track_scan_log: wrote to {} at {}".format(trigger_path, now))


def check_the_tracker():
    """Checks that the tracker file exists and that it's timestamp is recent"""
    tracker = _tracker_exists()
    if not tracker:
        _add_trigger()
        return 0

    if not _is_recent(tracker):
        _add_trigger()

    return 0


def main():
    """The command line entry point"""
    try:
        check_the_tracker()
        return 0
    except Exception:  # pylint: disable=broad-except
        _print(traceback.format_exc())
        return 1


if __name__ == '__main__':
    sys.exit(main())
