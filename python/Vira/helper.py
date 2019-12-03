#!/usr/bin/env python
'''
Helper functions for vira
These functions don't reference the jira API
'''
# dev: let b:startapp = "python "
# dev: let b:startfile = "%"
# dev: let b:startargs = ""

# TODO-MB [191128] - Make yaml optional
import yaml
import datetime

def timestamp():
    '''
    Selected for Development
    '''

    return str(datetime.datetime.now())

def parse_yaml(file_path) -> dict:
    '''
    Load configuration from yaml file into dictionary
    '''

    try:
        with open(file_path, 'r') as yamlFile:
            config = yaml.load(yamlFile, Loader=yaml.FullLoader)
    except OSError as e:
        print(e)
        return

    return config

def load_config(file_path):
    '''
    Load user configuration file
    '''

    # TODO-MB [191128] - Put json/yaml if statement here
    return parse_yaml(file_path)

if __name__ == '__main__':
    'For testing purposes'
    pass
