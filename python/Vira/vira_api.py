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

    def add_comment(self, issue, comment):
        '''
        Comment on specified issue
        '''

        self.jira.add_comment(issue, comment)

    def add_issue(self, project, summary, description, issuetype):
        '''
        Get single issue by isuue id
        '''

        self.jira.create_issue(
            project={'key': project},
            summary=summary,
            description=description,
            issuetype={'name': issuetype})

    def add_worklog(self, issue, timeSpentSeconds, comment):
        '''
        Calculate the offset for the start time of the time tracking
        '''

        earlier = datetime.datetime.now() - datetime.timedelta(seconds=timeSpentSeconds)

        self.jira.add_worklog(
            issue=issue,
            timeSpentSeconds=timeSpentSeconds,
            comment=comment,
            started=earlier)

    def connect(self, server, user, pw, skip_cert_verify):
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

    def filter_str(self, startQuery, queryType):
        '''
        Build a filter string to add to a JQL query
        '''

        query = ''
        evals = vim.eval('g:vira_filter_' + queryType)
        if set(evals) and evals != '':
            if set(startQuery) and startQuery != '':
                query = ' AND '
            else:
                query = ''

            query += queryType + ' in ('
            if isinstance(evals, list):
                query += ',' . join(evals)
            else:
                query += evals

            query += ')'

        return query

    def get_comments(self, issue):
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
                f"{comment['updated'][11:16]}" + ' | ', f"{comment['body']} + '\n'")

        return comments

    def get_epics(self):
        '''
        Get my issues with JQL
        '''

        for issue in self.query_issues(issuetypes="Epic"):
            print(issue["key"] + '  -  ' + issue["fields"]['summary'])

    def get_issue(self, issue):
        '''
        Get single issue by isuue id
        '''

        return self.jira.issue(issue)

    def get_issues(self):
        '''
        Get my issues with JQL
        '''

        #  issues = []
        for issue in self.query_issues():
            print(issue["key"] + '  -  ' + issue["fields"]['summary'])
            #  issues.append(issue["key"] + '  -  ' + issue["fields"]['summary'])
        #  return str(issues)

    def get_issuetypes(self):
        '''
        Get my issues with JQL
        '''

        for issuetype in self.jira.issue_types():
            print(issuetype)

    def get_priorities(self):
        '''
        Get my issues with JQL
        '''

        for priority in self.jira.priorities():
            print(priority)

    def get_projects(self):
        '''
        Build a vim popup menu for a list of projects
        '''

        for project in self.jira.projects():
            print(project)

    def get_report(self):
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
        report = issue + ': ' + f"{issues['issues'][0]['fields']['summary']}"
        report += '\nDetails {{' + '{1'
        report += "\nStory Points  :  "
        report += f"{issues['issues'][0]['fields']['customfield_10106']}"
        report += "\n     Created  :  "
        report += f"{issues['issues'][0]['fields']['created'][0:10]}"
        report += ' ' + f"{issues['issues'][0]['fields']['created'][11:16]}"
        report += "\n     Updated  :  "
        report += f"{issues['issues'][0]['fields']['updated'][0:10]}"
        report += ' ' + f"{issues['issues'][0]['fields']['updated'][11:16]}"
        report += "\n        Type  :  "
        report += f"{issues['issues'][0]['fields']['issuetype']['name']}"
        report += "\n      Status  :  "
        report += f"{issues['issues'][0]['fields']['status']['name']}"
        report += "\n    Priority  :  "
        report += f"{issues['issues'][0]['fields']['priority']['name']}"

        report += "\n    Assignee  :  "
        try:
            report += f"{issues['issues'][0]['fields']['assignee']['displayName']}"
        except:
            report += "Unassigned"

        report += "\n    Reporter  :  "
        report += f"{issues['issues'][0]['fields']['reporter']['displayName']}"
        report += '\n}}' + '}'
        report += '\nDescription {{' + '{1'
        report += f"\n{issues['issues'][0]['fields']['description']}"
        report += '\n}}' + '}'
        report += "\nComments {" + "{{1"
        for comment in issues['issues'][0]['fields']['comment']['comments']:
            report += f"\n{comment['author']['displayName']}" + ' @ '
            report += f"{comment['updated'][0:10]}" + ' '
            report += f"{comment['updated'][11:16]}" + ' {' + '{{2'
            report += f"\n{comment['body']}"
            report += '\n}}' + '}'
        report += "\n}}" + "}"

        return report

    def get_servers(self):
        '''
        Get my issues with JQL
        '''

        for server in vim.eval("g:vira_srvs"):
            print(server)

    def get_statuses(self):
        '''
        Get my issues with JQL
        '''

        for status in self.jira.statuses():
            print(status)

    def get_users(self):
        '''
        Get my issues with JQL
        '''

        for user in self.jira.search_users("."):
            print(user)

    def query_issues(self):
        '''
        Query issues based on current filters
        '''

        query = ''
        try:
            if (vim.eval('g:vira_project') != '' and vim.eval('g:vira_project') != vim.eval('g:vira_null_project')):
                query += 'project in (' + vim.eval('g:vira_project') + ')'
        except:
            query += ''
        queryTypes = ['status', 'issuetype']
        for queryType in queryTypes:
            query += self.filter_str(query, queryType)

        query += 'ORDER BY updated DESC'

        issues = self.jira.search_issues(
            query,
            fields='summary,comment',
            json_result='True')

        return issues['issues']

    def set_status(self, issue, status):
        '''
        Set the status of the given issue
        '''

        self.jira.transition_issue(issue, status)

    def timestamp():
        '''
        Selected for Development
        '''

        return str(datetime.datetime.now())

api = ViraAPI()
