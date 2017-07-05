#!/usr/bin/env python
"""A module that execute commands to overclock nvidia chips.

Prequisites: overclock values should be present in automine/overclock.json

"""

from __future__ import print_function

import json
import os
import subprocess
import sys


_LIST_GPUS_CMD = "nvidia-smi --query-gpu=name,pci.sub_device_id,index --format=csv,noheader"


def _sibling_path(name):
    """Compute path of file relative to this module."""
    here = os.path.dirname(os.path.join(os.getcwd(), __file__))
    return os.path.normpath(os.path.join(here, name))


def perform_overclock(cfgs):
    """Perform the overclock."""
    gpus_with_index = subprocess.check_output(_LIST_GPUS_CMD.split())
    one_gpu_script = _sibling_path('overclock_one_gpu.sh')
    for (name, sub_device, index) in [l.split(', ') for l in gpus_with_index.splitlines()]:
        index = index.strip()
        sub_device_spec = 'pci.sub_device_id:' + sub_device
        by_name = cfgs.get(name)
        by_spec = cfgs.get(sub_device_spec)
        if by_name is None and by_spec is None:
            print("Skipped {0}({1}) at #{2}, no config set for it".format(name, sub_device_spec, index))
        else:
            the_cfg = by_spec or by_name
            print("Overclocking {0}({1}) at #{2}".format(name, sub_device_spec, index))
            child_env = dict(os.environ)
            child_env['NVD_GPU_INDEX'] = index
            for name, value in iter(the_cfg.items()):
                child_env["NVD_{0}".format(name.upper())] = str(value)
            print(subprocess.check_output(one_gpu_script,
                                          executable='/bin/bash',
                                          env=child_env,
                                          shell=True))


def main():
    """The comamnd line entry point """
    cfg_path = _sibling_path('../overclock.json')
    if not os.path.exists(cfg_path):
        print("No overclock.json at {}, exiting".format(cfg_path))
        sys.exit(1)
    try:
        cfg_dict = json.load(open(cfg_path))
        cfgs = cfg_dict.get('nvidia')
        if not isinstance(cfgs, dict):
            raise ValueError("Did not find overclocks in {}".format(cfg_path))
        print("configuration found at {0}".format(cfg_path))
        perform_overclock(cfgs)
    except ValueError as err:
        print("Error overclocking using the cfg: {0}, exiting".format(cfg_path))
        print(err)
        sys.exit(1)


if __name__ == '__main__':
    main()
