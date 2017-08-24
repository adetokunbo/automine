#!/usr/bin/env python
"""A module that execute commands to overclock nvidia chips.

Prequisites: overclock values should be present in ~/.automine/automine_config.json

"""

from __future__ import print_function

import json
import logging
import os
import sys


def _log_name():
    """The name to use for logging"""
    return os.path.splitext(os.path.basename(__file__))[0]


_LOG = logging.getLogger(_log_name())


def _sibling_path(name):
    """Compute path of file relative to this module."""
    here = os.path.dirname(os.path.join(os.getcwd(), __file__))
    return os.path.normpath(os.path.join(here, name))


def _get_sub_cfg(sub_name, the_cfg):
    """Obtain a subsection of the cfg"""
    sub_cfg = the_cfg.get(sub_name)
    if not isinstance(sub_cfg, dict):
        raise ValueError("missing {} in config".format(sub_name))
    return sub_cfg


_WORKER_ID = 'full-worker-id'
_ETHMINER_SHORT_OPTS = {
    'main-pool': '-S',
    'fallback-pool': '-FS',
    _WORKER_ID: '-O',
}


def _format_ethminer_opt(name, value):
    if isinstance(value, dict):
        return ''
    if name in _ETHMINER_SHORT_OPTS:
        return "{} {}".format(_ETHMINER_SHORT_OPTS[name], value)
    return "--{} {}".format(name, value)


_ETHMINER_RIG_TYPE_OPTS = {
    'nvidia': '-U',
    'amdgpu': '-G',
}


def _show_ethminer_opts(the_cfg):
    """Generate text to specify the configured ethminer options in a command line"""
    cfg = _get_sub_cfg('ethminer', the_cfg)
    cfg[_WORKER_ID] = "{}.{}".format(cfg.pop('wallet'), cfg.pop('worker'))
    rig_type = _get_sub_cfg('environment', the_cfg)['RIG_TYPE']
    rig_type_opt = [_ETHMINER_RIG_TYPE_OPTS[rig_type]]
    _fmt = _format_ethminer_opt
    other_opts = [_fmt(key, value) for (key, value) in iter(cfg.iteritems())]
    return " ".join(rig_type_opt + other_opts)


def _show_shell_exports(the_cfg):
    """Generate text to declare the configured export variables in a bash shell"""
    cfg = _get_sub_cfg('environment', the_cfg)
    as_exports = [
        "{}={}".format(key, val) for key, val in iter(cfg.iteritems())
    ]
    return " ".join(["export"] + as_exports)


def _show_ethminer_exports(the_cfg):
    """Generate text to declare the configured ethminer export variables in a bash shell"""
    ethminer_cfg = _get_sub_cfg('ethminer', the_cfg)
    fallback_pool_var = "FALLBACK_POOL={}".format(ethminer_cfg[
        'fallback-pool'])
    if not 'environment' in ethminer_cfg:
        return "export " + fallback_pool_var
    return _show_shell_exports(ethminer_cfg) + " " + fallback_pool_var


def _show_cfg(the_cfg):
    """Show the config as pretty-printed json"""
    return json.dumps(the_cfg, indent=2)


_ENV_VAR = 'AUTOMINE_CFG_PATH'
_DEFAULT_PATH = os.path.expanduser('~/.automine/automine_config.json')


def _cfg_path():
    """Determines the path of the configuration file

    It checks the value of the environment variable AUTOMINE_CFG_PATH, and uses
    that if the file exists. Otherwise, it use the default value, or returns
    None

    """
    from_env = os.environ.get(_ENV_VAR)
    if from_env and os.path.isfile(from_env):
        return from_env
    elif os.path.isfile(_DEFAULT_PATH):
        return _DEFAULT_PATH
    else:
        _LOG.error('no config found, specify it with $%s', _ENV_VAR)
        return None


KNOWN_ACTIONS = {
    'shell_exports': _show_shell_exports,
    'ethminer_exports': _show_ethminer_exports,
    'ethminer_opts': _show_ethminer_opts,
    'none': _show_cfg,
}


def _what_action(argv):
    """use argv to decide how to show the config"""
    action = 'none' if len(argv) < 2 else argv[1]
    return 'none' if action not in KNOWN_ACTIONS else action


def main(argv=None):
    """The command line entry point"""
    logging.basicConfig()
    action = _what_action(sys.argv) if argv is None else _what_action(argv)
    try:
        cfg_path = _cfg_path()
        if not cfg_path:
            return 1
        the_cfg = json.load(open(cfg_path))
        if not isinstance(the_cfg, dict):
            raise ValueError("missing config in {}".format(cfg_path))
        print(KNOWN_ACTIONS[action](the_cfg))
        return 0
    except ValueError:
        _LOG.error(
            "error using the config: %s, exiting", cfg_path, exc_info=True)
        return 1
    except Exception:  # pylint: disable=broad-except
        _LOG.error('could not show config', exc_info=True)
        return 1


if __name__ == '__main__':
    sys.exit(main())
