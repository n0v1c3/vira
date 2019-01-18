#!/usr/bin/env python2
'''
Internals and API functions for vira
'''

# File: py/vira.vim {{{1
# Description: Internals and API functions for vira
# Authors:
#   n0v1c3 (Travis Gall) <https://github.com/n0v1c3>
# Version: 0.0.1

# dev: let b:startapp = "pipenv run python "
# dev: let b:startargs = "--help"

# Imports {{{1

from jira import JIRA
import argparse
import datetime
import getpass

# Arguments {{{1

# Parse arguments and show __doc__ and defaults in --help

parser = argparse.ArgumentParser(
    description=__doc__, formatter_class=argparse.ArgumentDefaultsHelpFormatter)

parser.add_argument(
    '-u', '--user', action='store', default='travis.gall', help='Jira username')

parser.add_argument('-p', '--password', action='store', help='Jira password')

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

    return JIRA(options={'server': server}, auth=(user, pw))

# Issues {{{1
# My Issues {{{2
def vira_my_issues():
    '''
    Get my issues with JQL
    '''

    issues = jira.search_issues(
        'project = AC AND resolution = Unresolved AND assignee in (currentUser()) ORDER BY priority DESC, updated DESC',
        fields='summary,comment',
        json_result='True')
    #  print(issues)
    match = []
    for issue in issues["issues"]:
        print(issue['key'] + ' | ' + issue['fields']['summary'])
        match.append("{\"abbr\": \"%s\", \"menu\": \"%s\"}" % (str(
            issue["key"]), issue["fields"]["summary"].replace(
                "\"", "\\\"")))  # issue['fields']['summary'].replace("\"", "\\\"")))
    return ','.join(match)

# Issue {{{2
def vira_get_issue(issue):
    '''
    Get single issue by isuue id
    '''

    return jira.issue(issue)

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
        '" AND project = AC AND resolution = Unresolved ORDER BY priority DESC, updated DESC',
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
    Selected for Development
    In Progress
    Done
    '''

    jira.transition_issue(issue, status)

# Testing {{{1

def main():  # {{{2
    '''
    Main script entry point
    '''

    global jira

    # Get pw if not passed with --password
    mypass = args.password if args.password else getpass.getpass(
        prompt='Password: ', stream=None)

    # Establish connection to JIRA
    jira = vira_connect(args.server, args.user, mypass)

    print('')
    print('Active Issues')
    print('=============')
    vira_my_issues()
    print('')
    issue = vira_get_issue('AC-186')
    print('Issue: ' + issue.key)
    print(vira_get_comments(issue))

    print('')
    issue = vira_get_issue('AC-159')
    print('Issue: ' + issue.key)
    print(vira_get_comments(issue))

    # print(vira_add_comment(issue, 'I need another comment for testing'))
    # vira_set_status(issue, 'Selected for Development')
    # vira_add_worklog(issue, 600, 'Comment goes here:\n-List of file touched\n-Another file touched')

# Main {{{1

# Run script if this file is executed directly
if __name__ == '__main__':
    args = parser.parse_args()
    main()

# Garbage {{{1
# print(vira_add_comment(issue, 'First test comment to this issue'))

#  issues = jira.search_issues('status in ("In Progress", "To Do") AND resolution = Unresolved AND assignee in (currentUser()) ORDER BY updated ASC, priority DESC')
#  for issue in issues:
#  print("==========")
#  print(str(issue))
#  print("==========")
#  comments = json.loads(json.dumps(jira.search_issues('issue = \'' + str(issue) + '\' AND status in ("In Progress", "To Do") AND resolution = Unresolved AND assignee in (currentUser()) ORDER BY updated ASC, priority DESC',fields = 'comment',json_result ='True')))
#  for issue in comments["issues"]:
#  for comment in issue["fields"]["comment"]["comments"]:
#  print(comment["author"]["name"] + " | " + comment["created"][0:10] + " || " + comment["body"])

#  print("")
