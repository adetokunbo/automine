#!/usr/bin/env python
"""A module that execute commands to overclock nvidia chips.

Prequisites: overclock values should be present in
$HOME/.automine/automine_config.json

"""

from __future__ import print_function

import json
import logging
from logging.config import dictConfig
import os
import subprocess
import sys

_SYSFS_PREFIX = '/sys/class/drm/card'
_LIST_SYSFS_GPUS_CMD = "/bin/ls -1 {}*/device/hwmon/hwmon*/name".format(
    _SYSFS_PREFIX)


def _log_name():
    """The name to use for logging"""
    return os.path.splitext(os.path.basename(__file__))[0]


_LOG = logging.getLogger(_log_name())


def _info(some_text, headline=None):
    lines = tuple(some_text.splitlines())
    if headline:
        banner = '-' * len(headline)
        lines = (banner, headline, banner) + lines
    for line in lines:
        _LOG.info(line)


def _sibling_path(name):
    """Compute path of file relative to this module."""
    here = os.path.dirname(os.path.join(os.getcwd(), __file__))
    return os.path.normpath(os.path.join(here, name))


def _is_amd(sysfs_gpu_name):
    """Determine if a sysfs_gpu_name file indicates an AMD device"""
    with open(sysfs_gpu_name) as src:
        return src.read().strip() == 'amdgpu'


def _amd_index(sysfs_gpu_name):
    """Determine the gpu index given a sysfs_gpu_name"""
    drop_prefix = sysfs_gpu_name.strip()[len(_SYSFS_PREFIX):]
    return drop_prefix.split('/')[0]


def perform_overclock(the_cfg):
    """Perform the overclock."""
    sysfs_cards = subprocess.check_output(_LIST_SYSFS_GPUS_CMD, shell=True)
    gpu_indices = [
        _amd_index(x) for x in sysfs_cards.splitlines() if _is_amd(x.strip())
    ]
    one_gpu_script = _sibling_path('overclock_one_gpu.sh')
    for index in gpu_indices:
        child_env = dict(os.environ)
        child_env['AMD_GPU_INDEX'] = index
        for env_name, value in iter(the_cfg.items()):
            child_env["AMD_{0}".format(env_name.upper())] = str(value)
        headline = "updating gpu {}".format(index)
        _info(
            subprocess.check_output(
                one_gpu_script,
                executable='/bin/bash',
                env=child_env,
                shell=True),
            headline=headline)


_DEFAULT_PATH = os.path.expanduser('~/.automine/automine_config.json')


def _cfg_path(argv):
    """Determines the path of the configuration file"""
    cfg_path = argv[1] if len(argv) > 1 else None
    _is_file = os.path.isfile
    if not cfg_path or not _is_file(cfg_path):
        if cfg_path:
            _info("no config at {}, trying the default location".format(
                cfg_path))
        cfg_path = _DEFAULT_PATH
    if not _is_file(cfg_path):
        _info("no config at {}, exiting".format(cfg_path))
        return None
    return cfg_path


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


def main(argv=None):
    """The command line entry point"""
    if argv is None:
        argv = sys.argv
    try:
        _configure_logger()
        cfg_path = _cfg_path(argv)
        if not cfg_path:
            return 1
        the_cfg = json.load(open(cfg_path)).get('amdgpu')
        if not isinstance(the_cfg, dict):
            raise ValueError("missing config in {}".format(cfg_path))
        _info("loaded config from {0}".format(cfg_path))
        perform_overclock(the_cfg)
        return 0
    except ValueError:
        _LOG.error(
            "error using the config: %s, exiting", cfg_path, exc_info=True)
        return 1
    except Exception:  # pylint: disable=broad-except
        _LOG.error('could not perform overclock', exc_info=True)
        return 1


if __name__ == '__main__':
    sys.exit(main())
