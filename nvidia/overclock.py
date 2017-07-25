#!/usr/bin/env python
"""A module that execute commands to overclock nvidia chips.

Prequisites: overclock values should be present in automine/overclock.json

"""

from __future__ import print_function

import json
import os
import subprocess
import sys
import traceback

_LIST_GPUS_CMD = "nvidia-smi --query-gpu=name,pci.sub_device_id,index --format=csv,noheader"


def _print(some_text, headline=None):
    with open("/tmp/overclock_log.out", "a") as out:
        lines = (some_text,)
        if headline:
            full_headline = "overclock: {}".format(headline)
            banner = '-' * len(full_headline)
            lines = (banner, full_headline, banner, some_text)
        for line in lines:
            print(line.encode('utf8'), file=out)


def _sibling_path(name):
    """Compute path of file relative to this module."""
    here = os.path.dirname(os.path.join(os.getcwd(), __file__))
    return os.path.normpath(os.path.join(here, name))


def perform_overclock(cfgs):
    """Perform the overclock."""
    gpus_with_index = subprocess.check_output(_LIST_GPUS_CMD.split())
    one_gpu_script = _sibling_path('overclock_one_gpu.sh')
    for (name, sub_device,
         index) in [l.split(', ') for l in gpus_with_index.splitlines()]:
        index = index.strip()
        sub_device_spec = 'pci.sub_device_id:' + sub_device
        by_name = cfgs.get(name)
        by_spec = cfgs.get(sub_device_spec)
        if by_name is None and by_spec is None:
            _print("overclock: skipped {0}({1}) at #{2}, no config set for it".
                   format(name, sub_device_spec, index))
        else:
            the_cfg = by_spec or by_name
            child_env = dict(os.environ)
            child_env['NVD_GPU_INDEX'] = index
            for env_name, value in iter(the_cfg.items()):
                child_env["NVD_{0}".format(env_name.upper())] = str(value)
            headline = "updating gpu{:02d} ({}/{})".format(
                int(index), name, sub_device_spec)
            _print(
                subprocess.check_output(
                    one_gpu_script,
                    executable='/bin/bash',
                    env=child_env,
                    shell=True),
                headline=headline)


def _cfg_path(argv):
    """Determines the path of the configuration file"""
    cfg_path = argv[1] if len(argv) > 1 else None
    _exists = os.path.exists
    if not cfg_path or not _exists(cfg_path):
        if cfg_path:
            _print("overclock: no config at {}, trying the default location".
                   format(cfg_path))
        cfg_path = _sibling_path('../overclock.json')
    if not _exists(cfg_path):
        _print("overclock: no config at {}, exiting".format(cfg_path))
        return None
    return cfg_path


def main(argv=None):
    """The comamnd line entry point"""
    if argv is None:
        argv = sys.argv
    try:
        cfg_path = _cfg_path(argv)
        if not cfg_path:
            return 1
        cfgs = json.load(open(cfg_path)).get('nvidia')
        if not isinstance(cfgs, dict):
            raise ValueError("overclock: missing config in {}".format(
                cfg_path))
        _print("overclock: loaded config from {0}".format(cfg_path))
        perform_overclock(cfgs)
        return 0
    except ValueError as err:
        _print("overclock: error using the config: {0}, exiting".format(
            cfg_path))
        _print(str(err))
        return 1
    except Exception as err:  # pylint: disable=broad-except
        _print(traceback.format_exc(), headline="overclock: {}".format(err))
        return 1


if __name__ == '__main__':
    sys.exit(main())
