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
    try:
        jira = JIRA(options={'server': server}, auth=(user, pw), timeout=5)
        vim.command("let s:vira_is_init = 1")
    except:
        vim.command("let s:vira_is_init = 0")

# Issues {{{1
def vira_set_issue(): # {{{2
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
        # 'project = AC AND resolution = Unresolved AND assignee in (currentUser()) ORDER BY updated DESC, priority DESC',
        query + 'resolution = Unresolved AND assignee in (currentUser()) ORDER BY updated DESC',
        fields='summary,comment',
        json_result='True')

    # Rebuild the menu
    vim.command('redraw')
    vim.command('amenu&Vira.&<tab>:e :<cr>')
    vim.command('aunmenu &Vira')
    vim.command('amenu&Vira.&' +
                vim.eval('g:vira_null_issue').replace(" ", "\\ ") +
                '<tab>:e :call vira#_set_active_issue("' +
                vim.eval('g:vira_null_issue').replace(" ", "\\ ") +
                '")<cr>')
    for issue in issues["issues"]:
        vim.command("amenu&Vira.&" +
                    issue["key"] + "\ -\ " +
                    issue["fields"]["summary"].replace(" ", "\\ ") +
                    '<tab>:e :let g:vira_active_issue = "' +
                    issue["key"] + '"<cr>')

    #  return ','.join(match)

def vira_add_issue(issue): # {{{2
    '''
    Get single issue by isuue id
    '''

    return jira.issue(issue)

def vira_statusline():
    '''
    Get single issue by isuue id
    '''

    #  return vim.eval('ViraGetActiveIssue()')
    return "Test"

def vira_get_issue(issue): # {{{2
    '''
    Get single issue by isuue id
    '''

    return jira.issue(issue)

# Function {{{1
# Projects {{{2
def vira_get_projects():
    '''
    Build a vim popup menu for a list of projects
    '''

    projects = jira.projects()
    vim.command('redraw')
    vim.command('amenu&Vira.&<tab>:e :<cr>')
    vim.command('aunmenu &Vira')
    vim.command('amenu&Vira.&' +
                vim.eval('g:vira_null_project').replace(" ", "\\ ") +
                '<tab>:e :call vira#_set_active_issue("' +
                vim.eval('g:vira_null_project').replace(" ", "\\ ") +
                '")<cr>')
    for project in projects:
        vim.command("amenu&Vira.&" + str(project) +
                    '<tab>:e :silent! let g:vira_project="' +
                    str(project) + '"<cr>')

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

    issues = jira.search_issues(
        'issue = "' + issue.key +
        # '" AND project = AC AND resolution = Unresolved ORDER BY priority DESC, updated DESC',
        '" AND resolution = Unresolved ORDER BY priority DESC, updated DESC',
        fields='summary,comment',
        json_result='True')
    comments = ''
    for comment in issues["issues"][0]["fields"]["comment"]["comments"]:
        comments += comment['author']['displayName'] + ' | ' + comment['updated'][
            0:10] + ' @ ' + comment['updated'][11:16] + ' | ' + comment['body'] + '\n'

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

def vira_report(issue):
    '''
    Print a report for the given issue
    '''

    issues = jira.search_issues(
        'issue = "' + issue +
        # '" AND project = AC AND resolution = Unresolved ORDER BY priority DESC, updated DESC',
        '" AND resolution = Unresolved ORDER BY priority DESC, updated DESC',
        fields='summary,comment,description',
        json_result='True')

    # print("Issue:\n" + issue + ' | ' + issues["issues"][0]["fields"]["summary"])
    print(issue + ' | ' + str(issues["issues"][0]["fields"]["summary"]))
    # print("Details:")
    print('\nDescription:\n' + str(issues["issues"][0]["fields"]["description"]))

    print("\nComments:")
    print("----------")
    for comment in issues["issues"][0]["fields"]["comment"]["comments"]:
        print(comment['author']['displayName'] + ' @ ' + comment['updated'][
            0:10] + ' ' + comment['updated'][11:16])
        print(comment['body'])
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
