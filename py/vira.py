#!/usr/bin/env python3
'''
Internals and API functions for vira
'''

# File: py/vira.vim {{{1
# Description: Internals and API functions for vira
# Authors:
#   n0v1c3 (Travis Gall) <https://github.com/n0v1c3>
#   mike.boiko (Mike Boiko) <https://github.com/mikeboiko>
# Version: 0.0.1

# Imports {{{1
from __future__ import print_function, unicode_literals
import vim
from jira import JIRA
import datetime
import urllib3

# Functions {{{1
# Connect {{{2
def vira_connect(server, user, pw, skip_cert_verify): # {{{3
    '''
    Connect to Jira server with supplied auth details
    '''

    global jira

    # Specify whether the server's TLS certificate needs to be verified
    if skip_cert_verify == "1":
        urllib3.disable_warnings(urllib3.exceptions.InsecureRequestWarning)
        cert_verify = False
    else:
        cert_verify = True

    try:
        jira = JIRA(options={'server': server, 'verify': cert_verify}, auth=(user, pw), timeout=5)
        vim.command("let s:vira_is_init = 1")
    except:
        vim.command("let s:vira_is_init = 0")

# Issues {{{2
def vira_str(string): # {{{3
    '''
    Protect strings from JIRA for Python and Vim
    '''

    return str(string)

def vira_str_amenu(string): # {{{3
    '''
    Protect strings from JIRA for Python and Vim
    '''

    string = string.replace("\\", "\\\\")
    string = string.replace(".", r"\.")
    string = string.replace(" ", "\\ ")
    return string

def vira_query_issues(): # {{{3
    query = ''
    try:
        if (vim.eval('g:vira_project') != ''):
            query += 'project in (' + vim.eval('g:vira_project') + ') AND '
    except:
        query += ''

    #  TODO: VIRA-47 [190923] - Unique calls required for exitsing query
    query += 'resolution = Unresolved '
    #  query += ' AND assignee in (currentUser()) '
    query += 'ORDER BY updated DESC'

    issues = jira.search_issues(
        query,
        fields='summary,comment',
        json_result='True')

    return issues['issues']

def vira_get_issues(): # {{{3
    '''
    Get my issues with JQL
    '''

    for issue in vira_query_issues():
        print(issue["key"] + '  -  ' + issue["fields"]['summary'])

def vira_add_issue(project, summary, description, issuetype): # {{{3
    '''
    Get single issue by isuue id
    '''

    jira.create_issue(project={'key': project},
                      summary=summary,
                      description=description,
                      issuetype={'name': issuetype})

def vira_get_issue(issue): # {{{3
    '''
    Get single issue by isuue id
    '''

    return jira.issue(issue)

# Projects {{{2
def vira_query_projects(): # {{{3

    return jira.projects()

def vira_get_projects(): # {{{3
    '''
    Build a vim popup menu for a list of projects
    '''

    for project in vira_query_projects():
        print(project)

# Comments {{{2
def vira_add_comment(issue, comment): # {{{3
    '''
    Comment on specified issue
    '''

    jira.add_comment(issue, comment)

def vira_get_comments(issue): # {{{3
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

# Worklog {{{2
def vira_add_worklog(issue, timeSpentSeconds, comment): # {{{3
    '''
    Calculate the offset for the start time of the time tracking
    '''

    earlier = datetime.datetime.now() - datetime.timedelta(seconds=timeSpentSeconds)

    jira.add_worklog(
        issue=issue, timeSpentSeconds=timeSpentSeconds, comment=comment, started=earlier)

# Report {{{2
def vira_get_report(): # {{{3
    '''
    Print a report for the given issue
    '''

    # Get passed issue content

    issue = vim.eval("g:vira_active_issue")
    issues = jira.search_issues('issue = "' + issue + '"',
                                #  fields='*',
                                fields='summary,comment,' +
                                       'description,issuetype,' +
                                       'priority,status,' +
                                       'created,updated,' +
                                       'assignee,reporter,' +
                                       'customfield_10106,',
                                json_result='True')

    # Print issue content
    print(issue + ': ' + vira_str(issues["issues"][0]["fields"]["summary"]))
    print('Details {{' + '{1')
    print("Story Points  :  " + vira_str(issues["issues"][0]["fields"]["customfield_10106"]))
    print("     Created  :  " + vira_str(issues["issues"][0]["fields"]["created"][0:10]) +
          ' ' + vira_str(issues["issues"][0]["fields"]["created"][11:16]))
    print("     Updated  :  " + vira_str(issues["issues"][0]["fields"]["updated"][0:10]) +
          ' ' + vira_str(issues["issues"][0]["fields"]["updated"][11:16]))
    print("        Type  :  " + vira_str(issues["issues"][0]["fields"]["issuetype"]["name"]))
    print("      Status  :  " + vira_str(issues["issues"][0]["fields"]["status"]["name"]))
    print("    Priority  :  " + vira_str(issues["issues"][0]["fields"]["priority"]["name"]))

    print("    Assignee  :  ", end="")
    try:
        print(vira_str(issues["issues"][0]["fields"]["assignee"]["displayName"]))
    except:
        print("Unassigned")

    print("    Reporter  :  " + vira_str(issues["issues"][0]["fields"]["reporter"]['displayName']))
    print('}}' + '}')
    print('Description {{' + '{1')
    print(vira_str(issues["issues"][0]["fields"]["description"]))
    print('}}' + '}')
    print("Comments {" + "{{1")
    for comment in issues["issues"][0]["fields"]["comment"]["comments"]:
        print(vira_str(comment['author']['displayName']) + ' @ ' +
              vira_str(comment['updated'][0:10]) + ' ' +
              vira_str(comment['updated'][11:16]) + ' {' + '{{2')
        print(vira_str(comment['body']))
        print('}}' + '}')
    print("}}" + "}",)

# Status {{{2
def vira_set_status(issue, status): # {{{3
    '''
    Set the status of the given issue
    '''

    jira.transition_issue(issue, status)

# Time {{{2
def vira_timestamp(): # {{{3
    '''
    Selected for Development
    '''

    return str(datetime.datetime.now())

# Main {{{1
def main(): # {{{2
    '''
    Main script entry point
    Used for testing
    '''

    # Create a connection
    #  jira = vira_connect(vim.eval("g:vira_serv"), vim.eval("g:vira_user"), vim.eval("g:vira_pass"))
    #  vim.command("let s:vira_is_init = 0")

# Run script if this file is executed directly
if __name__ == '__main__': # {{{2
    main()
