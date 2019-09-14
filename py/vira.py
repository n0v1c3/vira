#!/usr/bin/env python2
'''
Internals and API functions for vira
'''

# File: py/vira.vim {{{1
# Description: Internals and API functions for vira
# Authors:
#   n0v1c3 (Travis Gall) <https://github.com/n0v1c3>
#   mike.boiko (Mike Boiko) <https://github.com/mikeboiko>
# Version: 0.0.1

# dev: let b:startapp = "pipenv run python "
# dev: let b:startargs = "--help"

# Imports {{{1
import vim
from jira import JIRA
import argparse
import datetime
import urllib3

# Arguments {{{1
# Parse arguments and show __doc__ and defaults in --help
# Parser {{{2
parser = argparse.ArgumentParser(
    description=__doc__, formatter_class=argparse.ArgumentDefaultsHelpFormatter)

# User {{{2
parser.add_argument(
    '-u', '--user', action='store', default='travis.gall', help='Jira username')

parser.add_argument('-p', '--password', action='store', help='Jira password')

# Server {{{2
parser.add_argument(
    '-s',
    '--server',
    action='store',
    default='https://jira.boiko.online',
    help='URL of jira server')

# Connect {{{1
def vira_connect(server, user, pw):
    '''
    Connect to Jira server with supplied auth details
    '''
    global jira

    # TODO: VIRA-49 [190911] - make this optional
    urllib3.disable_warnings(urllib3.exceptions.InsecureRequestWarning)

    try:
        jira = JIRA(options={'server': server, 'verify': False}, auth=(user, pw), timeout=5)
        vim.command("let s:vira_is_init = 1")
    except:
        vim.command("let s:vira_is_init = 0")

# Issues {{{1
def vira_add_issue(issue): # {{{2
    '''
    Get single issue by isuue id
    '''

    return jira.issue(issue)

def vira_get_issue(issue): # {{{2
    '''
    Get single issue by isuue id
    '''

    return jira.issue(issue)

# Functions {{{1
# Issues {{{2

def vira_str(string): # {{{3
    '''
    Protect strings from JIRA for Python and Vim
    '''
    return string

def vira_str_amenu(string):
    '''
    Protect strings from JIRA for Python and Vim
    '''
    string = string.replace("\\", "\\\\")
    string = string.replace(".", "\.")
    string = string.replace(" ", "\\ ")
    return string

def vira_set_issue(): # {{{3
    '''
    Get my issues with JQL
    '''

    query = ''
    try:
        if (vim.eval('g:vira_project') != ''):
            query += 'project = ' + vim.eval('g:vira_project') + ' AND '
    except:
        query += ''

    issues = jira.search_issues(
        query + 'resolution = Unresolved AND assignee in (currentUser()) ORDER BY updated DESC',
        fields='summary,comment',
        json_result='True')

    #  TODO-TJG [190213] - This is almost exactly the same as vira_get_projects() should be merged into a single function.
    # Rebuild the menu
    vira_null_issue = vira_str_amenu(vim.eval('g:vira_null_issue'))
    vim.command('redraw')
    vim.command('amenu&Vira.&<tab>:exec :<cr>')
    vim.command('aunmenu &Vira')
    vim.command('amenu&Vira.&' +
                vira_null_issue + '<tab>:exec :call vira#_set_active_issue("' +
                vira_null_issue + '")<cr>')
    for issue in issues["issues"]:
        key = vira_str_amenu(issue["key"])
        vim.command("amenu&Vira.&" +
                    vira_str_amenu(key + " " + issue["fields"]["summary"]) +
                    '<tab>:exec :let g:vira_active_issue = "' + key + '"<cr>')

# Projects {{{2
def vira_get_projects(): # {{{3
    '''
    Build a vim popup menu for a list of projects
    '''

    # Get a list of project keys from Jira
    projects = jira.projects()

    # Rebuild the menu
    vira_null_project = vira_str_amenu(vim.eval('g:vira_null_project'))
    vim.command('redraw')
    vim.command('amenu&Vira.&<tab>:exec :<cr>')
    vim.command('aunmenu &Vira')
    vim.command('amenu&Vira.&' + vira_null_project +
                '<tab>:exec :call vira#_set_active_issue("' +
                vira_null_project + '")<cr>')
    for project in projects:
        project = vira_str_amenu(str(project))
        vim.command("amenu&Vira.&" + project +
                    '<tab>:exec :silent! let g:vira_project="' +
                    project + '"<cr>')

# Comments {{{1
def vira_add_comment(issue, comment):
    '''
    Comment on specified issue
    '''

    jira.add_comment(issue, comment)

def vira_get_comments(issue):
    '''
    Get all the comments for an issue
    '''

    # Get the issue requested
    issues = jira.search_issues('issue = "' + issue.key + '"',
                                fields='summary,comment',
                                json_result='True')

    # Loop through all of the comments
    comments = ''
    for comment in issues["issues"][0]["fields"]["comment"]["comments"]:
        comments += (vira_str(comment['author']['displayName']) + ' | ',
                     vira_str(comment['updated'][0:10]) + ' @ ',
                     vira_str(comment['updated'][11:16]) + ' | ',
                     vira_str(comment['body'] + '\n'))

    return comments

# Worklog {{{1
def vira_add_worklog(issue, timeSpentSeconds, comment):
    '''
    Calculate the offset for the start time of the time tracking
    '''

    earlier = datetime.datetime.now() - datetime.timedelta(seconds=timeSpentSeconds)

    jira.add_worklog(
        issue=issue, timeSpentSeconds=timeSpentSeconds, comment=comment, started=earlier)

# Status {{{1
def vira_set_status(issue, status):
    '''
    Set the status of the given issue
    '''

    jira.transition_issue(issue, status)

# Time {{{1
def vira_timestamp():
    '''
    Selected for Development
    '''

    return str(datetime.datetime.now())

# Print a report of the given issue key
def vira_report(issue):
    '''
    Print a report for the given issue
    '''

    # Get passed issue content
    issues = jira.search_issues('issue = "' + issue + '"',
                                fields='summary,comment,description',
                                json_result='True')

    # Print issue content
    print(issue + ' | ' + vira_str(issues["issues"][0]["fields"]["summary"]))
    print('Description: ' + vira_str(issues["issues"][0]["fields"]["description"]))
    print("\nComments:")
    print("----------")
    for comment in issues["issues"][0]["fields"]["comment"]["comments"]:
        print(vira_str(comment['author']['displayName']) + ' @ ' +
              vira_str(comment['updated'][0:10]) + ' ' +
              vira_str(comment['updated'][11:16]))
        print(vira_str(comment['body']))
        print("----------")

# Main {{{1
def main():
    '''
    Main script entry point
    '''

    '''
    # Get pw if not passed with --password
    mypass = args.password if args.password else getpass.getpass(
        prompt='Password: ', stream=None)
    '''

    # Create a connection
    #  jira = vira_connect(vim.eval("g:vira_serv"), vim.eval("g:vira_user"), vim.eval("g:vira_pass"))
    #  vim.command("let s:vira_is_init = 0")

# Run script if this file is executed directly
if __name__ == '__main__':
    args = parser.parse_args()
    main()
