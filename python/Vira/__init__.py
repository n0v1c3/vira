#!/usr/bin/env python
"""Entry point for vira"""

from .vira_api import *  # noqa F403
from .helper import *  # noqa F403

# TODO-MB [191128] - Temporary
# Read user-defined vira config
file_path = '/home/mike/.config/vira/vira_servers.yaml'
read_config(file_path)
