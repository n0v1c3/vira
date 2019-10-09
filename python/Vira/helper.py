#!/usr/bin/env python
'''
Helper functions for vira
These functions don't reference the jira API
'''

import vim
import datetime

def get_servers(self):
    '''
    Get my issues with JQL
    '''

    for server in vim.eval("g:vira_srvs"):
        print(server)

def timestamp():
    '''
    Selected for Development
    '''

    return str(datetime.datetime.now())
