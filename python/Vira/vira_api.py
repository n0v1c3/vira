#!/usr/bin/env python3
# dev: let b:startapp = 'vim "+Vader! /mnt/cloud/temp/test1.vader"'
# dev: let b:startfile = ''
# dev: let b:startargs = ''
'''
Internals and API functions for vira
'''

from __future__ import print_function, unicode_literals
import vim
from jira import JIRA
from jira.exceptions import JIRAError
import datetime
import urllib3
from Vira.helper import load_config, run_command

class ViraAPI():
    '''
    This class gets imported by __init__.py
    '''

    def __init__(self):
        '''
        Initialize vira
        '''

        # Load user-defined config files
        file_servers = vim.eval('g:vira_config_file_servers')
        file_projects = vim.eval('g:vira_config_file_projects')
        try:
            self.vira_servers = load_config(file_servers)
            self.vira_projects = load_config(file_projects)
        except:
            print(f'Could not load {file_servers} or {file_projects}')

        self.vim_filters_default = {
            'assignee': '',
            'component': '',
            'fixVersion': '',
            'issuetype': '',
            'priority': '',
            'project': '',
            'reporter': '',
            'status': '',
            'statusCategory': ['To Do', 'In Progress']
        }
        self.reset_filters()

    def create_issue(self, input_stripped):
        '''
        Create new issue in jira
        '''

        summary = input_stripped[input_stripped.find('[Summary]') +
                                 9:input_stripped.find('[Description]')].strip().replace(
                                     '\n', ' ')
        description = input_stripped[input_stripped.find('[Description]') +
                                     len('[Description]'):input_stripped.
                                     find('[Project]')].strip().replace(
                                         '\n', ' ')  # noqa 126
        project = input_stripped[input_stripped.find('[Project]') +
                                 len('[Project]'):input_stripped.
                                 find('[IssueType]')].strip().replace(
                                     '\n', ' ')  # noqa 126
        issuetype = input_stripped[input_stripped.find('[IssueType]') +
                                   len('[IssueType]'):input_stripped.
                                   find('[Status]')].strip().replace('\n', ' ')
        status = input_stripped[input_stripped.find('[Status]') +
                                len('[Status]'):input_stripped.find('[Priority]')].strip(
                                ).replace('\n', ' ')  # noqa 126
        priority = input_stripped[input_stripped.find('[Priority]') +
                                  len('[Priority]'):input_stripped.
                                  find('[Component]')].strip().replace('\n', ' ')
        component = input_stripped[input_stripped.find('[Component]') +
                                   len('[Component]'):input_stripped.
                                   find('[Version]')].strip().replace('\n', ' ')
        version = input_stripped[input_stripped.find('[Version]') +
                                 len('[Version]'):input_stripped.
                                 find('[Assignee]')].strip().replace('\n', ' ')
        assignee = input_stripped[input_stripped.find('[Assignee]') + 10:].strip()

        # # TODO-MB [200522] - TEST
        # vim.command(f"let g:testvar = '{locals()}'")
        # vim.command("let g:testvar = '" + str(self.vim_filters['project']) + "'")
        return

        # Check if summary was entered by user
        if summary == '':
            return

        issue_key = self.jira.create_issue(
            project=project,
            summary=summary,
            description=description,
            issuetype={'name': issuetype},
            priority={'name': priority},
            components=[{
                'name': component
            }],
            fixVersions=[{
                'name': version
            }],
            assignee={'name': assignee})
        self.jira.transition_issue(issue_key, status)

        jira_server = vim.eval('g:vira_serv')
        print(f'Added {jira_server}/browse/{issue_key}')

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

    def connect(self, server):
        '''
        Connect to Jira server with supplied auth details
        '''

        # Specify whether the server's TLS certificate needs to be verified
        if self.vira_servers[server].get('skip_cert_verify'):
            urllib3.disable_warnings(urllib3.exceptions.InsecureRequestWarning)
            cert_verify = False
        else:
            cert_verify = True

        # Get auth for current server
        username = self.vira_servers[server].get('username')
        password_cmd = self.vira_servers[server].get('password_cmd')
        if password_cmd:
            password = run_command(password_cmd)['stdout'].strip()
        else:
            password = self.vira_servers[server]['password']

        # Connect to jira server
        try:
            self.jira = JIRA(
                options={
                    'server': server,
                    'verify': cert_verify
                },
                auth=(username, password),
                timeout=5)
            vim.command('echo "Connection to jira server was successful"')
        except JIRAError as e:
            if 'CAPTCHA' in str(e):
                vim.command(
                    'echo "Could not log into jira! Check authentication details and log in from web browser to enter mandatory CAPTCHA."'
                )
            else:
                raise e

    def filter_str(self, filterType):
        '''
        Build a filter string to add to a JQL query
        The string will look similar to one of these:
            AND status in ('In Progress')
            AND status in ('In Progress', 'To Do')
        '''

        if self.vim_filters.get(filterType, '') == '':
            return

        selection = str(self.vim_filters[filterType]).strip('[]') if type(
            self.
            vim_filters[filterType]) == list else self.vim_filters[filterType] if type(
                self.vim_filters[filterType]
            ) == tuple else "'" + self.vim_filters[filterType] + "'"

        return f"{filterType} in ({selection})"

    def get_assign_issue(self):
        '''
        Menu to select users
        '''

        self.get_users()

    def get_assignees(self):
        '''
        Get my issues with JQL
        '''

        self.get_users()

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

    def get_components(self):
        '''
        Build a vim popup menu for a list of components
        '''

        for component in self.jira.project_components(self.vim_filters['project']):
            print(component.name)

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

        # issues = []
        for issue in self.query_issues():
            print(
                issue["key"] + "  ~  " + issue["fields"]["summary"] + " | " +
                issue["fields"]["status"]["name"] + " |")
            #  issues.append(issue["key"] + '  -  ' + issue["fields"]['summary'])
        # return str(issues)

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

    def get_prompt_text(self, prompt_type):
        '''
        Get prompt text used for inputting text into jira
        '''

        # Prepare dynamic variables for prompt text
        users = [
            user.key
            for user in self.jira.search_users(".")
            if not user.key.startswith('JIRAUSER')
        ]
        statuses = [x.name for x in self.jira.statuses()]
        issuetypes = [x.name for x in self.jira.issue_types()]
        priorities = [x.name for x in self.jira.priorities()]
        components = [
            x.name for x in self.jira.project_components(self.vim_filters['project'])
        ] if self.vim_filters['project'] != '' else ''
        versions = [
            x.name for x in self.jira.project_versions(self.vim_filters['project'])
        ] if self.vim_filters['project'] != '' else ''
        projects = [x.key for x in self.jira.projects()]

        self.prompt_type = prompt_type
        self.prompt_text_commented = f'''\n# Please enter the {prompt_type} above this line
# Lines starting with '#' will be ignored. An empty message will abort the operation.
#
# Below is a list of acceptable values for each input field.
# The default values is indicated by round brackets.
# Projects: {projects}
# IssueTypes: {issuetypes}
# Statuses: {statuses}
# Priorities: {priorities}
# Components in {self.vim_filters["project"]} Project: {components}
# Versions in {self.vim_filters["project"]} Project: {versions}
# Users: {users}
'''
        if self.prompt_type == 'issue':
            text = f'''[Summary]

[Description]

[Project]
{self.vim_filters["project"]}

[IssueType]

[Status]

[Priority]

[Component]

[Version]

[Assignee]
{self.prompt_text_commented}'''
        else:
            text = self.prompt_text_commented

        return text

    def get_report(self):
        '''
        Print a report for the given issue
        '''

        # Get passed issue content
        active_issue = vim.eval("g:vira_active_issue")
        issues = self.jira.search_issues(
            'issue = "' + active_issue + '"',
            #  fields='*',
            fields=','.join(
                [
                    'summary,', 'comment,', 'component', 'description', 'issuetype,',
                    'priority', 'status,', 'created', 'updated,', 'assignee', 'reporter,',
                    'fixVersion', 'customfield_10106,'
                ]),
            json_result='True')
        issue = issues['issues'][0]['fields']

        # Prepare report data
        open_fold = '{{{'
        close_fold = '}}}'
        summary = issue['summary']
        story_points = str(issue.get('customfield_10106', ''))
        created = issue['created'][0:10] + ' ' + issues['issues'][0]['fields']['created'][
            11:16]
        updated = issue['updated'][0:10] + ' ' + issues['issues'][0]['fields']['updated'][
            11:16]
        task_type = issue['issuetype']['name']
        status = issue['status']['name']
        priority = issue['priority']['name']
        assignee = issue['assignee']['displayName'] if type(
            issue['assignee']) == dict else 'Unassigned'
        reporter = issue['reporter']['displayName']
        component = ', '.join([c['name'] for c in issue['components']])
        version = ', '.join([v['name'] for v in issue['fixVersions']])
        description = str(issue.get('description'))
        comments = '\n'.join(
            [
                comment['author']['displayName'] + ' @ ' + comment['updated'][0:10] +
                ' ' + comment['updated'][11:16] + ' {{{2\n' + comment['body'] + '\n}}}'
                for comment in issue['comment']['comments']
            ])

        # Create report template and fill with data
        report = '''{active_issue}: {summary}
Details {open_fold}1
Story Points   :  {story_points}
     Created   :  {created}
     Updated   :  {updated}
        Type   :  {task_type}
      Status   :  {status}
    Priority   :  {priority}
    Component  :  {component}
    Version    :  {version}
    Assignee   :  {assignee}
    Reporter   :  {reporter}
{close_fold}
Description {open_fold}1
{description}
{close_fold}
Comments {open_fold}1
{comments}
{close_fold}'''.format(**locals())

        return report

    def get_reporters(self):
        '''
        Get my issues with JQL
        '''

        self.get_users()

    def get_servers(self):
        '''
        Get list of servers
        '''

        for server in self.vira_servers.keys():
            print(server)

    def get_statuses(self):
        '''
        Get my issues with JQL
        '''

        for status in self.jira.statuses():
            print(status)

    def get_set_status(self):
        '''
        Get my issues with JQL
        '''

        self.get_statuses()

    def get_users(self):
        '''
        Get my issues with JQL
        '''

        users = [
            user.key
            for user in self.jira.search_users(".")
            if not user.key.startswith('JIRAUSER')
        ]
        for user in users:
            print(user)

    def get_versions(self):
        '''
        Build a vim popup menu for a list of versions
        '''

        for version in self.jira.project_versions(self.vim_filters['project']):
            print(version.name)

    def load_project_config(self):
        '''
        Load project configuration for the current git repo

        For example, an entry in projects.yaml may be:

        vira:
          server: https://jira.tgall.ca
          project_name: VIRA
        '''

        # Only proceed if projects file parsed successfully
        if not getattr(self, 'vira_projects', None):
            return

        repo = run_command('git rev-parse --show-toplevel')['stdout'].strip().split(
            '/')[-1]

        # If curren't repo doesn't exist, use __default__ project config if it exists
        if not self.vira_projects.get(repo):
            if self.vira_projects.get('__default__'):
                repo = '__default__'
            else:
                return

        server = self.vira_projects.get(repo, {}).get('server')
        if server:
            vim.command(f'let g:vira_serv = "{server}"')

        for filterType in self.vim_filters.keys():
            filterValue = self.vira_projects.get(repo, {}).get('filter', {}).get(filterType)
            if filterValue:
                self.vim_filters[filterType] = filterValue

    def query_issues(self):
        '''
        Query issues based on current filters
        '''

        q = []
        for filterType in self.vim_filters.keys():
            filter_str = self.filter_str(filterType)
            if filter_str:
                q.append(filter_str)

        query = ' AND '.join(q) + ' ORDER BY updated DESC'
        issues = self.jira.search_issues(
            query,
            fields='summary,comment,status,statusCategory',
            json_result='True',
            maxResults=-1)

        return issues['issues']

    def reset_filters(self):
        '''
        Reset filters to their default values
        '''

        self.vim_filters = dict(self.vim_filters_default)

    def write_jira(self):
        '''
        Write to jira
        Can be issue name, description, comment, etc...
        '''

        # User input
        issue = vim.eval('g:vira_active_issue')
        input_stripped = vim.eval('g:vira_input_text').replace(
            self.prompt_text_commented.strip(), '').strip()

        # Check if anything was actually entered by user
        if input_stripped == '':
            return

        if self.prompt_type == 'comment':
            self.jira.add_comment(issue, input_stripped)
        elif self.prompt_type == 'issue':
            self.create_issue(input_stripped)
