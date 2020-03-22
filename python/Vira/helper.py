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

def load_config(file_path) -> dict:
    '''
    Load user configuration file
    '''

    if 'json' in file_path.lower():
        config = parse_json(file_path)
    else:
        config = parse_yaml(file_path)

    return load_templates(config)

def load_templates(config) -> dict:
    '''
    Replace template key with template values
    If the user defined a key on a project level that already existed on a
    template level, the project key will override the template key.
    '''

    # Create copy of original dictionary
    template_config = dict(config)

    for key, value in config.items():
        if value.get('template'):
            template = dict(config[value.get('template')])
            template.update(template_config[key])
            template_config[key].update(template)

    return template_config

def parse_json(file_path) -> dict:
    '''
    Load configuration from json file into dictionary
    '''

    try:
        with open(file_path, 'r') as file:
            config = json.load(file)
    except OSError as e:
        raise e

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
        raise e

    return config

def run_command(cmd_string):
    '''
    Run bash command and return dictionary with the keys:
    {'stdout', 'stderr', 'exitcode'}
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
