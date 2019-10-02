#!/usr/bin/env python
"""Entry point for vira"""

# TODO-MB [190924] - This is the plan:
# - Test: vi -c q
# - rename vira.py to vira_manager.py
# - rename functions to remove leading vira_
# - from Vira.vira_manager import ViraManager
# - Call py function from vim as such: ViraManager.vira_test()
#   see UltiSnips_Manager.add_buffer_filetypes()
# - Separate vim part of vira so I can run python tests on their own
# - Search out all TODO-MB and fix them

from Vira.vira import *
