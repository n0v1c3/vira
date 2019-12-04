#!/usr/bin/env python
'''
Helper functions for vira
These functions don't reference the jira API
'''
# dev: let b:startapp = "python "
# dev: let b:startfile = "%"
# dev: let b:startargs = ""

import json
import datetime
import subprocess

def load_config(file_path):
    '''
    Load user configuration file
    '''

    if 'json' in file_path.lower():
        return parse_json(file_path)
    else:
        return parse_yaml(file_path)

def parse_json(file_path) -> dict:
    '''
    Load configuration from json file into dictionary
    '''

    try:
        with open(file_path, 'r') as file:
            config = json.load(file)
    except OSError as e:
        print(e)
        return

    return config

def parse_yaml(file_path) -> dict:
    '''
    Load configuration from yaml file into dictionary
    '''

    import yaml
    try:
        with open(file_path, 'r') as file:
            config = yaml.load(file, Loader=yaml.FullLoader)
    except OSError as e:
        print(e)
        return

    return config

def run_command(cmd_string):
    '''
    Run bash command and return dictionary with the keys:
    '''

    # Run process
    process = subprocess.Popen(
        cmd_string.split(), stdout=subprocess.PIPE, stderr=subprocess.PIPE, shell=False)
    output, error = process.communicate()

    # Prepare output dictionary
    return {
        'stdout': output.decode('utf-8'),
        'stderr': error.decode('utf-8'),
        'exitcode': process.returncode,
    }

def timestamp():
    '''
    Selected for Development
    '''

    return str(datetime.datetime.now())

if __name__ == '__main__':
    'For testing purposes'
    pass
