#!/usr/bin/env python3
"""A module that execute commands to overclock nvidia chips.

Prequisites: overclock values should be present in ~/.automine/automine_config.json
or in a file specified as an argument

"""

import json
import logging
from logging.config import dictConfig
import os
import subprocess
import sys

_LIST_GPUS_CMD = "nvidia-smi --query-gpu=name,pci.sub_device_id,index --format=csv,noheader"


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


def perform_overclock(cfgs):
    """Perform the overclock."""
    gpus_with_index = subprocess.check_output(_LIST_GPUS_CMD.split())
    one_gpu_script = _sibling_path('overclock_one_gpu.sh')
    lines = gpus_with_index.splitlines()
    for (name, sub_device, index) in [l.decode().split(', ') for l in lines]:
        index = index.strip()
        _LOG.info("name is %s, index is %s", name, index)
        sub_device_spec = 'pci.sub_device_id:' + sub_device
        by_name = cfgs.get(name)
        by_spec = cfgs.get(sub_device_spec)
        if by_name is None and by_spec is None:
            _info("skipped {0}({1}) at #{2}, no config set for it".format(
                name, sub_device_spec, index))
        else:
            the_cfg = by_spec or by_name
            child_env = dict(os.environ)
            child_env['NVD_GPU_INDEX'] = index
            for env_name, value in iter(list(the_cfg.items())):
                child_env["NVD_{0}".format(env_name.upper())] = str.format(
                    "{}", value)
            headline = "updating gpu{:02d} ({}/{})".format(
                int(index), name, sub_device_spec)
            _info(
                subprocess.check_output(
                    one_gpu_script,
                    executable='/bin/bash',
                    env=child_env,
                    shell=True).decode(),
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


def main(argv=None):
    """The command line entry point"""
    if argv is None:
        argv = sys.argv
    try:
        _configure_logger()
        cfg_path = _cfg_path(argv)
        if not cfg_path:
            return 1
        cfgs = json.load(open(cfg_path)).get('nvidia')
        if not isinstance(cfgs, dict):
            raise ValueError("missing config in {}".format(cfg_path))
        _info("loaded config from {0}".format(cfg_path))
        perform_overclock(cfgs)
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
