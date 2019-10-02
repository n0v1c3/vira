#!/usr/bin/env python
"""Entry point for vira"""

# TODO-MB [190924] - This is the plan:
# - rename vira.py to vira_manager.py
# - rename functions to remove leading vira_
# - Call py function from vim as such: ViraManager.vira_test()
#   see UltiSnips_Manager.add_buffer_filetypes()
# - Separate vim part of vira so I can run python tests on their own
# - Search out all TODO-MB and fix them
# - add leading _ to all internal functions

from .vira import *  # noqa F401
