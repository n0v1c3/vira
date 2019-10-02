#!/usr/bin/env python3
'''
Internals and API functions for vira
'''

from __future__ import print_function, unicode_literals
import vim
from jira import JIRA
import datetime
import urllib3

class ViraAPI():
    '''
    This class gets imported by __init__.py
    '''

    def vira_add_comment(self, issue, comment):
        '''
        Comment on specified issue
        '''

        self.jira.add_comment(issue, comment)

    def vira_add_issue(self, project, summary, description, issuetype):
        '''
        Get single issue by isuue id
        '''

        self.jira.create_issue(
            project={'key': project},
            summary=summary,
            description=description,
            issuetype={'name': issuetype})

    def vira_add_worklog(self, issue, timeSpentSeconds, comment):
        '''
        Calculate the offset for the start time of the time tracking
        '''

        earlier = datetime.datetime.now() - datetime.timedelta(seconds=timeSpentSeconds)

        self.jira.add_worklog(
            issue=issue,
            timeSpentSeconds=timeSpentSeconds,
            comment=comment,
            started=earlier)

    def vira_connect(self, server, user, pw, skip_cert_verify):
        '''
        Connect to Jira server with supplied auth details
        '''

        # Specify whether the server's TLS certificate needs to be verified
        if skip_cert_verify == "1":
            urllib3.disable_warnings(urllib3.exceptions.InsecureRequestWarning)
            cert_verify = False
        else:
            cert_verify = True

        try:
            self.jira = JIRA(
                options={
                    'server': server,
                    'verify': cert_verify
                },
                auth=(user, pw),
                timeout=5)
            vim.command("let s:vira_is_init = 1")
        except:
            vim.command("let s:vira_is_init = 0")

    def vira_get_comments(self, issue):
        '''
        Get all the comments for an issue
        '''

        # Get the issue requested
        issues = self.jira.search_issues(
            'issue = "' + issue.key + '"', fields='summary,comment', json_result='True')

        # Loop through all of the comments
        comments = ''
        for comment in issues["issues"][0]["fields"]["comment"]["comments"]:
            comments += (
                f"{comment['author']['displayName']}" + ' | ',
                f"{comment['updated'][0:10]}" + ' @ ',
                f"{comment['updated'][11:16]}" + ' | ',
                f"{comment['body']} + '\n'")

        return comments

    def vira_get_epics(self):
        '''
        Get my issues with JQL
        '''

        for issue in self.vira_query_issues(issuetypes="Epic"):
            print(issue["key"] + '  -  ' + issue["fields"]['summary'])

    def vira_get_issue(self, issue):
        '''
        Get single issue by isuue id
        '''

        return self.jira.issue(issue)

    def vira_get_issues(self):
        '''
        Get my issues with JQL
        '''

        for issue in self.vira_query_issues():
            print(issue["key"] + '  -  ' + issue["fields"]['summary'])

    def vira_get_issuetypes(self):
        '''
        Get my issues with JQL
        '''

        for issuetype in self.jira.issue_types():
            print(issuetype)

    def vira_get_priorities(self):
        '''
        Get my issues with JQL
        '''

        for priority in self.jira.priorities():
            print(priority)

    def vira_get_projects(self):
        '''
        Build a vim popup menu for a list of projects
        '''

        for project in self.vira_query_projects():
            print(project)

    def vira_get_report(self):
        '''
        Print a report for the given issue
        '''

        # Get passed issue content

        issue = vim.eval("g:vira_active_issue")
        issues = self.jira.search_issues(
            'issue = "' + issue + '"',
            #  fields='*',
            fields='summary,comment,' + 'description,issuetype,' + 'priority,status,' +
            'created,updated,' + 'assignee,reporter,' + 'customfield_10106,',
            json_result='True')

        # Print issue content
        print(issue + ': ' + f"{issues['issues'][0]['fields']['summary']}")
        print('Details {{' + '{1')
        print(
            "Story Points  :  " +
            f"{issues['issues'][0]['fields']['customfield_10106']}")
        print(
            "     Created  :  " +
            f"{issues['issues'][0]['fields']['created'][0:10]}" + ' ' +
            f"{issues['issues'][0]['fields']['created'][11:16]}")
        print(
            "     Updated  :  " +
            f"{issues['issues'][0]['fields']['updated'][0:10]}" + ' ' +
            f"{issues['issues'][0]['fields']['updated'][11:16]}")
        print(
            "        Type  :  " +
            f"{issues['issues'][0]['fields']['issuetype']['name']}")
        print(
            "      Status  :  " +
            f"{issues['issues'][0]['fields']['status']['name']}")
        print(
            "    Priority  :  " +
            f"{issues['issues'][0]['fields']['priority']['name']}")

        print("    Assignee  :  ", end="")
        try:
            print(f"{issues['issues'][0]['fields']['assignee']['displayName']}")
        except:
            print("Unassigned")

        print(
            "    Reporter  :  " +
            f"{issues['issues'][0]['fields']['reporter']['displayName']}")
        print('}}' + '}')
        print('Description {{' + '{1')
        print(f"{issues['issues'][0]['fields']['description']}")
        print('}}' + '}')
        print("Comments {" + "{{1")
        for comment in issues['issues'][0]['fields']['comment']['comments']:
            print(
                f"{comment['author']['displayName']}" + ' @ ' +
                f"{comment['updated'][0:10]}" + ' ' +
                f"{comment['updated'][11:16]}" + ' {' + '{{2')
            print(f"{comment['body']}")
            print('}}' + '}')
        print("}}" + "}",)

    def vira_get_statuses(self):
        '''
        Get my issues with JQL
        '''

        for status in self.jira.statuses():
            print(status)

    def vira_get_users(self):
        '''
        Get my issues with JQL
        '''

        for user in self.jira.search_users("."):
            print(user)

    def vira_query_issues(
            self, status="", priorities="", issuetypes="", reporters="", assignees=""):
        query = ''
        try:
            if (vim.eval('g:vira_project') != ''):
                query += 'project in (' + vim.eval('g:vira_project') + ') AND '
        except:
            query += ''

        if set(status):
            query += 'status in (' + status + ') AND '

        if set(priorities):
            query += 'status in (' + status + ') AND '

        if set(issuetypes):
            query += 'issuetype in (' + issuetypes + ') AND '

        if set(reporters):
            query += 'reporter in (' + reporters + ') AND '

        if set(assignees):
            query += 'assignee in (' + assignees + ') AND '

        #  TODO: VIRA-81 [190928] - Custom queries besed on menu {{{
        query += 'resolution = Unresolved '
        #  query += ' AND assignee in (currentUser()) '
        query += 'ORDER BY updated DESC'
        #  }}}

        issues = self.jira.search_issues(
            query, fields='summary,comment', json_result='True')

        return issues['issues']

    def vira_query_projects(self):

        return self.jira.projects()

    def vira_set_status(self, issue, status):
        '''
        Set the status of the given issue
        '''

        self.jira.transition_issue(issue, status)

    def vira_test(self):
        # TODO-MB [190924] - delete after testing is complete
        vim.command('let g:testvar = "testpy"')

def vira_get_servers():
    '''
    Get my issues with JQL
    '''

    for server in vim.eval("g:vira_srvs"):
        print(server)

def vira_timestamp():
    '''
    Selected for Development
    '''

    return str(datetime.datetime.now())

api = ViraAPI()
