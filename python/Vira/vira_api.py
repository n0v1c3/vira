#!/usr/bin/env python3
'''
Internals and API functions for vira
'''

from __future__ import print_function, unicode_literals
from Vira.helper import load_config, run_command, parse_prompt_text
from Vira.db import ViraDB
from jira import JIRA
from jira.exceptions import JIRAError
from datetime import datetime
import json
import urllib3
import vim

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
        file_db = vim.eval('g:vira_config_file_db')

        try:
            self.vira_servers = load_config(file_servers)
            self.vira_projects = load_config(file_projects)
        except:
            print(f'Could not load {file_servers} or {file_projects}')

        # Create the database file
        self.vira_db = file_db
        self.db_serv = []
        self.updated_date = 0
        self.update_issues = []
        self.last_issues = []
        self.ViraDB = ViraDB()

        self.userconfig_filter_default = {
            'assignee': '',
            'component': '',
            'fixVersion': '',
            'issuetype': '',
            'priority': '',
            'project': '',
            'reporter': '',
            'status': '',
            "'Epic Link'": '',
            'statusCategory': ['To Do', 'In Progress'],
            'text': ''
        }
        self.reset_filters()

        self.userconfig_newissue = {
            'assignee': '',
            'component': '',
            'fixVersion': '',
            'issuetype': 'Bug',
            'priority': '',
            'epics': '',
            'status': '',
        }

        self.userconfig_issuesort = 'updated DESC'

        self.users = set()
        self.servers = set()
        self.users_type = ''

        self.versions_hide(True)

    def __missing__(self, key):
        if '(' in key and key.endswith(')'):
            key, rest = key.split('(', 1)
            value = super().__getitem__(key)
            suffix = rest.rstrip(')').split(',')
            if len(suffix) == 1:
                suffix.insert(0, '')
                return suffix[0] if value <= 1 else suffix[1]
            raise KeyError(key)

    def _async(self, func):
        '''
        Initialize vira
        '''

        try:
            func()
        except:
            pass

    def _async_db(self):
        '''
        Initialize vira
        '''

        if self.ViraDB.jql_start_at is not None:
            self.ViraDB.db_connect('TRUE')
            try:
                latest_issue = self.ViraDB.latest_issue()
                vim.command('let g:vira_updated_issue = "' + str(latest_issue[9]) + '-' + str(latest_issue[3]) + '"')
            except:
                pass

            try:
                vim.command('let g:vira_async_timer = g:vira_async_fast')
                self.ViraDB.jql_issue(self.ViraDB.update_issues[int(self.ViraDB.jql_offset)])
                self.ViraDB.jql_offset = int(self.ViraDB.jql_offset) + 1
            except:
                vim.command('let g:vira_async_timer = g:vira_async_sleep')
                server = self.ViraDB.select_server(self._get_serv())

                self.ViraDB.last_issues = self.ViraDB.update_issues

                try:
                    self.ViraDB.update_server()
                except:
                    pass

                try:
                    self.ViraDB.update_issues = self.ViraDB.update_jql(self.jira)
                except:
                    try:
                        self.connect(self.ViraDB.select_server()[1])
                    except:
                        self._print_serv_stat('lost! Reconnecting!')
            self.ViraDB.db_connect('FALSE')

    def _get_serv(self):
        return str(vim.eval('g:vira_serv'))

    def _has_field(self, issue, field):
        return field in issue and type(issue[field]) == dict

    def _print_serv_stat(self, status):
        vim.command('echo "Connection to ' + self._get_serv() + ' was ' + str(status) + '"')

    def msg_server_fail(self):
        print('No `vira_servers.json/yaml` file found or, check the config! See `README.md` for more information.')

    def connect(self, server):
        '''
        Connect to Jira server with supplied auth details
        '''

        self.users = set()
        self.users_type = ''

        try:
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
                password = run_command(password_cmd)['stdout'].strip().split('\n')[0]
            else:
                password = self.vira_servers[server]['password']
        except:
            self.msg_server_fail()
            raise

        # Connect to jira server
        try:
            if 'https://' not in server.lower():
                server = 'https://' + server
                vim.command('let g:vira_serv = "' + server + '"')

            # Authorize
            self.jira = JIRA(
                options={
                    'server': server,
                    'verify': cert_verify,
                },
                basic_auth=(username, password),
                timeout=2,
                async_=True,
                max_retries=2)

            vim.command('let g:vira_serv = "' + server + '"')

            # Initial list updates (will create `db` if required)
            self.ViraDB.db_connect("TRUE")
            self.ViraDB.connect(server)

            # Get last updated date from server convert from int to date format
            update = self.ViraDB.last_update(server)
            update = str(update)
            self.updated_date = update
            if self.updated_date != str(0):
                self.updated_date = update[0:4] + '-' + update[4:6] + '-' + update[6:8] + ' ' + update[8:10] + ':' + update[10:12]

            self.users = self.get_users()
            self.get_projects()

            self.ViraDB.update_issues = self.ViraDB.update_jql(self.jira)
            self.ViraDB.db_connect("FALSE")

            self._print_serv_stat('successful!')
        except JIRAError as e:
            if 'CAPTCHA' in str(e):
                self._print_serv_stat('NOT successful! Check authentication details and log in from browser for mandatory CAPTCHA.')
            else:
                vim.command('let g:vira_serv = ""')
                raise e
        except:
            vim.command('let g:vira_serv = ""')
            self._print_serv_stat('NOT successful! See the README for vira_server.json information.')
            pass

    def add_worklog(self, issue, timeSpentSeconds, comment):
        '''
        Calculate the offset for the start time of the time tracking
        '''

        earlier = datetime.now() - datetime.timedelta(seconds=timeSpentSeconds)

        self.jira.add_worklog(
            issue=issue,
            timeSpentSeconds=timeSpentSeconds,
            comment=comment,
            started=earlier)

    def create_issue(self, input_stripped):
        '''
        Create new issue in jira
        '''

        section = {
            'summary': parse_prompt_text(input_stripped, '*Summary*', 'Description'),
            'description': parse_prompt_text(input_stripped, 'Description', '*Project*'),
            'project': parse_prompt_text(input_stripped, '*Project*', '*IssueType*'),
            'issuetype': parse_prompt_text(input_stripped, '*IssueType*', 'Status'),
            'status': parse_prompt_text(input_stripped, 'Status', 'Priority'),
            'priority': parse_prompt_text(input_stripped, 'Priority', 'Component'),
            'components': parse_prompt_text(input_stripped, 'Component', 'Version'),
            'fixVersions': parse_prompt_text(input_stripped, 'Version', 'Assignee'),
            'assignee': parse_prompt_text(input_stripped, 'Assignee'),
        }

        # Check if required fields was entered by user
        if section['summary'] == '' or section['project'] == '' or section[
                'issuetype'] == '':
            return

        issue_kwargs = {
            'project': section['project'],
            'summary': section['summary'],
            'description': section['description'],
            'issuetype': {
                'name': section['issuetype']
            },
            'priority': {
                'name': section['priority']
            },
            'components': [{
                'name': section['components']
            }],
            'fixVersions': [{
                'name': section['fixVersions']
            }],
            'assignee': {
                'name': section['assignee']
            },
        }

        # Jira API doesn't accept empty fields for certain keys
        for key in issue_kwargs.copy().keys():
            if section[key] == '':
                issue_kwargs.pop(key)

        # Create issue and transition
        issue_key = self.jira.create_issue(**issue_kwargs)
        if section['status'] != '':
            self.jira.transition_issue(issue_key, section['status'])

        jira_server = vim.eval('g:vira_serv')
        print(f'Added {jira_server}/browse/{issue_key}')

    def filter_str(self, filterType):
        '''
        Build a filter string to add to a JQL query
        The string will look similar to one of these:
            AND status in ('In Progress')
            AND status in ('In Progress', 'To Do')
        '''

        if self.userconfig_filter.get(filterType, '') == '':
            return

        selection = str(self.userconfig_filter[filterType]).strip('[]') if type(self.userconfig_filter[filterType]) == list else self.userconfig_filter[filterType] if type(self.userconfig_filter[filterType]) == tuple else "'" + self.userconfig_filter[filterType] + "'"

        return str(f"{filterType} in ({selection})").replace("'None'", "Null").replace("'Unassigned'", "Null").replace("'currentUser'", "currentUser()").replace("'currentUser()'", "currentUser()").replace("'currentuser'", "currentUser()").replace("'currentuser()'", "currentUser()").replace("'null'", "Null").replace(f"text in ({selection})", f"text ~ {selection}")

    def format_date(self, date):
        '''
        Initialize vira
        '''

        time = datetime.now().strptime(date, '%Y-%m-%dT%H:%M:%S.%f%z').astimezone()
        return str(time)[0:10] + ' ' + str(time)[11:19]

    def get_assign_issue(self):
        '''
        Menu to select users
        '''

        self.print_users()

    def get_assignees(self):
        '''
        Get my issues with JQL
        '''

        self.print_users()

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
        Build a vim pop-up menu for a list of components
        '''

        for component in self.jira.project_components(self.userconfig_filter['project']):
            print(component.name)
        print('None')

    def get_component(self):
        '''
        Build a vim pop-up menu for a list of components
        '''

        self.get_components()

    def get_epic(self):
        '''
        Initialize vira
        '''

        self.get_epics()

    def get_epics(self):
        '''
        Get my issues with JQL
        '''
        hold = dict(self.userconfig_filter)
        project = self.userconfig_filter['project']
        self.reset_filters()
        self.userconfig_filter["issuetype"] = "Epic"
        self.userconfig_filter["project"] = project
        self.get_issues()
        print('None')
        self.userconfig_filter = hold

    def get_issue(self, issue):
        '''
        Get single issue by issue id
        '''

        return self.jira.issue(issue)

    def get_issues(self):
        '''
        Get my issues with JQL
        '''

        issues = []
        key_length = 0
        summary_length = 0
        issuetype_length = 0
        status_length = 4
        user_length = 0

        for issue in self.query_issues():
            fields = issue['fields']

            user = str(fields['assignee']['displayName']) if self._has_field(
                fields, 'assignee') else 'Unassigned'
            user_length = len(user) if len(user) > user_length else user_length

            key_length = len(
                issue['key']) if len(issue['key']) > key_length else key_length

            summary = fields['summary']
            summary_length = len(
                summary) if len(summary) > summary_length else summary_length

            issuetype = fields['issuetype']['name']
            issuetype_length = len(
                issuetype) if len(issuetype) > issuetype_length else issuetype_length

            status = fields['status']['name']
            status_length = len(status) if len(status) > status_length else status_length

            issues.append(
                [
                    issue['key'], fields['summary'], fields['issuetype']['name'],
                    fields['status']['name'], user
                ])

        # Add min/max limits on summary length
        columns = vim.eval("&columns")
        min_summary_length = 25
        max_summary_length = int(
            columns) - key_length - issuetype_length - status_length - 28
        summary_length = min_summary_length if max_summary_length < min_summary_length else max_summary_length if summary_length > max_summary_length else summary_length

        for issue in issues:
            print(
                ('{: <' + str(key_length) + '}').format(issue[0]) + " │ " +
                ('{: <' + str(summary_length) + '}').format(issue[1][:summary_length]) +
                "  │ " + ('{: <' + str(issuetype_length) + '}').format(issue[2]) + " │ " +
                ('{: <' + str(status_length) + '}').format(issue[3]) + ' │ ' + issue[4])

    def get_issuetypes(self):
        '''
        Get my issues with JQL
        '''

        for issuetype in self.jira.issue_types():
            print(issuetype)

    def get_issuetype(self):
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
        Build a vim pop-up menu for a list of projects
        '''

        # Project filter for version list
        self.projects = []
        for project in self.jira.projects():
            self.projects.append(str(project))
        vim.command('let s:projects = ' + str(self.projects))

        return self.projects

    def get_priority(self):
        '''
        Build a vim pop-up menu for a list of projects
        '''

        self.get_priorities()

    def get_prompt_text(self, prompt_type, comment_id=None):
        '''
        Get prompt text used for inputting text into jira
        '''

        self.prompt_type = prompt_type

        # Edit filters
        if prompt_type == 'edit_filter':
            self.prompt_text_commented = '\n# Edit all filters in JSON format'
            self.prompt_text = json.dumps(
                self.userconfig_filter, indent=True) + self.prompt_text_commented
            return self.prompt_text

        # Edit summary
        active_issue = vim.eval("g:vira_active_issue")
        if prompt_type == 'summary':
            self.prompt_text_commented = '\n# Edit issue summary'
            summary = self.jira.search_issues(
                'issue = "' + active_issue + '"',
                fields=','.join(['summary']),
                json_result='True')['issues'][0]['fields']['summary']
            self.prompt_text = summary + self.prompt_text_commented
            return self.prompt_text

        # Edit description
        if prompt_type == 'description':
            self.prompt_text_commented = '\n# Edit issue description'
            description = self.jira.search_issues(
                'issue = "' + active_issue + '"',
                fields=','.join(['description']),
                json_result='True')['issues'][0]['fields'].get('description')
            if description:
                description = description.replace('\r\n', '\n')
            else:
                description = ''
            self.prompt_text = description + self.prompt_text_commented
            return self.prompt_text

        self.prompt_text_commented = '''
# ---------------------------------
# Please enter text above this line
# An empty message will abort the operation.
#
# Below is a list of acceptable values for each input field.
#
# Users:'''
        for user in self.users:
            user = user.split(' ~ ')
            name = user[0]
            id = user[1]
            if self.users_type == 'accountId':
                self.prompt_text_commented += f'''
# [{name}|~accountid:{id}]'''
            else:
                self.prompt_text_commented += f'''
# [~{id}]'''

        # Add comment
        if self.prompt_type == 'add_comment':
            self.prompt_text = self.prompt_text_commented
            return self.prompt_text

        # Edit comment
        if self.prompt_type == 'edit_comment':
            self.active_comment = self.jira.comment(active_issue, comment_id)
            self.prompt_text = self.active_comment.body + self.prompt_text_commented
            return self.prompt_text

        statuses = [x.name for x in self.jira.statuses()]
        issuetypes = [x.name for x in self.jira.issue_types()]
        priorities = [x.name for x in self.jira.priorities()]
        components = [
            x.name
            for x in self.jira.project_components(self.userconfig_filter['project'])
        ] if self.userconfig_filter['project'] != '' else ''
        versions = [
            x.name for x in self.jira.project_versions(self.userconfig_filter['project'])
        ] if self.userconfig_filter['project'] != '' else ''
        projects = [x.key for x in self.jira.projects()]

        # Extra info for prompt_type == 'issue'
        self.prompt_text_commented += f'''
#
# Projects: {projects}
# IssueTypes: {issuetypes}
# Statuses: {statuses}
# Priorities: {priorities}
# Components in {self.userconfig_filter["project"]} Project: {components}
# Versions in {self.userconfig_filter["project"]} Project: {versions}'''

        self.prompt_text = f'''[*Summary*]
[Description]

[*Project*] {self.userconfig_filter["project"]}
[*IssueType*] {self.userconfig_newissue["issuetype"]}
[Status] {self.userconfig_newissue["status"]}
[Priority] {self.userconfig_newissue["priority"]}
[Component] {self.userconfig_newissue["component"]}
[Version] {self.userconfig_newissue["fixVersion"]}
[Assignee] {self.userconfig_newissue["assignee"]}
{self.prompt_text_commented}'''
        return self.prompt_text

    def get_report(self):
        '''
        Print a report for the given issue
        '''

        for customfield in self.jira.fields():
            if customfield['name'] == 'Epic Link':
                epicID = customfield['id']

        # Get passed issue content
        active_issue = vim.eval("g:vira_active_issue")
        issues = self.jira.search_issues(
            'issue = "' + active_issue + '"',
            fields=','.join(
                [
                    'project', 'summary', 'comment', 'component', 'description',
                    'issuetype', 'priority', 'status', 'created', 'updated', 'assignee',
                    'reporter', 'fixVersion', 'customfield_10106', 'labels', epicID
                ]),
            json_result='True')
        issue = issues['issues'][0]['fields']

        # Prepare report data
        open_fold = '{{{'
        close_fold = '}}}'
        summary = issue['summary']
        story_points = str(issue.get('customfield_10106', ''))
        created = self.format_date(issue['created'])
        updated = self.format_date(issue['updated'])
        issuetype = issue['issuetype']['name']
        status = issue['status']['name']
        priority = issue['priority']['name']
        assignee = issue['assignee']['displayName'] if self._has_field(
            issue, 'assignee') else 'Unassigned'
        reporter = issue['reporter']['displayName']
        component = ', '.join([c['name'] for c in issue['components']])
        version = ', '.join([v['name'] for v in issue['fixVersions']])
        epics = str(issue.get(epicID))
        vim.command(f'let s:vira_epic_field = "{epicID}"')
        description = str(issue.get('description'))

        #  Version percent for single version attacted
        if len(issue['fixVersions']) == 1 and version != '':
            version += ' | ' + self.version_percent(
                str(issue['project']['key']), version) + '%'

        comments = ''
        idx = 0
        for idx, comment in enumerate((issue['comment']['comments'])):
            comments += ''.join(
                [
                    comment['author']['displayName'] + ' @ ' +
                    self.format_date(comment['updated']) + ' {{' + '{2\n' +
                    comment['body'] + '\n}}}\n'
                ])
        old_count = idx - 3
        old_comment = 'Comment' if old_count == 1 else 'Comments'
        comments = ''.join(
            [str(old_count) + ' Older ' + old_comment +
             ' {{{1\n']) + comments if old_count >= 1 else comments
        comments = comments.replace('}}}', '}}}}}}', idx - 3)
        comments = comments.replace('}}}}}}', '}}}', idx - 4)

        # Find the length of the longest word [-1]
        words = [
            created, updated, issuetype, status, story_points, priority, component,
            version, assignee, reporter, epics
        ]
        wordslength = sorted(words, key=len)[-1]
        s = '─'
        dashlength = s.join([char * len(wordslength) for char in s])

        active_issue_spacing = int((16 + len(dashlength)) / 2 - len(active_issue) / 2)
        active_issue_spaces = ' '.join([char * (active_issue_spacing) for char in ' '])
        active_issue_space = ' '.join(
            [char * ((len(active_issue) + len(dashlength)) % 2) for char in ' '])

        created_spaces = ' '.join(
            [char * (len(dashlength) - len(created)) for char in ' '])
        updated_spaces = ' '.join(
            [char * (len(dashlength) - len(updated)) for char in ' '])
        task_type_spaces = ' '.join(
            [char * (len(dashlength) - len(issuetype)) for char in ' '])
        status_spaces = ' '.join([char * (len(dashlength) - len(status)) for char in ' '])
        story_points_spaces = ''.join(
            [char * (len(dashlength) - len(story_points)) for char in ' '])
        priority_spaces = ''.join(
            [char * (len(dashlength) - len(priority)) for char in ' '])
        component_spaces = ''.join(
            [char * (len(dashlength) - len(component)) for char in ' '])
        version_spaces = ''.join(
            [char * (len(dashlength) - len(version)) for char in ' '])
        assignee_spaces = ''.join(
            [char * (len(dashlength) - len(assignee)) for char in ' '])
        reporter_spaces = ''.join(
            [char * (len(dashlength) - len(reporter)) for char in ' '])
        epics_spaces = ''.join([char * (len(dashlength) - len(epics)) for char in ' '])

        # Create report template and fill with data
        report = '''┌────────────────{dashlength}─┐
│{active_issue_spaces}{active_issue}{active_issue_spaces}{active_issue_space} │
├──────────────┬─{dashlength}─┤
│      Created │ {created}{created_spaces} │
│      Updated │ {updated}{updated_spaces} │
│         Type │ {issuetype}{task_type_spaces} │
│       Status │ {status}{status_spaces} │
│ Story Points │ {story_points}{story_points_spaces} │
│     Priority │ {priority}{priority_spaces} │
│    Epic Link │ {epics}{epics_spaces} │
│ Component(s) │ {component}{component_spaces} │
│   Version(s) │ {version}{version_spaces} │
│     Assignee │ {assignee}{assignee_spaces} │
│     Reporter │ {reporter}{reporter_spaces} │
└──────────────┴─{dashlength}─┘
┌──────────────┐
│    Summary   │
└──────────────┘
{summary}

┌──────────────┐
│  Description │
└──────────────┘
{description}

┌──────────────┐
│   Comments   │
└──────────────┘
{comments}'''

        self.set_report_lines(report, description, issue)

        self.prompt_text = self.report_users(report.format(**locals()))
        return self.prompt_text

    def get_reporters(self):
        '''
        Get my issues with JQL
        '''

        self.print_users()

    def get_servers(self):
        '''
        Get list of servers
        '''

        try:
            if self.vira_servers.keys():
                count = len(self.vira_servers.keys())
                vim.command('let s:vira_serv_count = ' + str(count))

                if count > 1:
                    for server in self.vira_servers.keys():
                        print(server)
                elif count == 1:
                        server = str(list(self.vira_servers.keys())[0])
                        vim.command('let g:vira_serv = "{server}"')
                        self.connect(server)
            else:
                print('Null')
        except AttributeError as e:
            self.msg_server_fail()
        except:
            self.connect('')
            pass

    def get_statuses(self):
        '''
        Get my issues with JQL
        '''

        jira_statuses = []

        active_issue = vim.eval("g:vira_active_issue")
        if active_issue:
            try:
                issue = self.jira.issue(active_issue)
                jira_statuses = [t['name'] for t in self.jira.transitions(issue)]
            except:
                jira_statuses = self.jira.statuses()
        else:
            jira_statuses = self.jira.statuses()

        statuses = []
        for status in jira_statuses:
            if str(status) not in statuses:
                statuses.append(str(status))
                print(str(status))

    def get_set_status(self):
        '''
        Get my issues with JQL
        '''

        self.get_statuses()

    def get_versions(self):
        '''
        Get my issues with JQL
        '''

        #  print('│ Project Version Description Percent │')
        #  print('├────────┬───────┬───────────┬────────┤')

        try:
            versions = list()
            project = str()
            project_len = int()
            description_len = int()
            percent_len = int()
            version_len = int()
            s = '│'

            self.ViraDB.db_connect('TRUE')
            for version in self.ViraDB.select_versions():
                if str(version[0]) != str(project):
                    project = str(version[0])
                    project_len = len(project) if len(project) > project_len else project_len
                description = str(version[2])
                description_len = len(description) if len(description) > description_len else description_len
                percent = str(version[3])
                percent_len = len(percent) if len(percent) > percent_len else percent_len
                version = str(version[1])
                version_len = len(version) if len(version) > version_len else version_len
                versions.append([project, version, description, percent])
            self.ViraDB.db_connect('FALSE')

            for version in sorted(versions):
                p_len = project_len - len(version[0])
                v_len = version_len - len(version[1])
                d_len = description_len - len(version[2])
                c_len = percent_len - len(version[3])
                print(
                    '│ ' +
                    str(version[0]) + str(' ' * p_len) + ' │ ' +
                    str(version[1]) + str(' ' * v_len) + ' │ ' +
                    str(version[2]) + str(' ' * d_len) + ' │ ' +
                    str(version[3]) + '%' + str(' ' * c_len) +
                    ' │'
                )
        except OSError as e:
            print(e)
            pass

    def get_users(self):
        '''
        Get my issues with JQL
        '''

        query = 'ORDER BY updated DESC'
        issues = self.jira.search_issues(
            query, fields='assignee, reporter', json_result='True', maxResults=-1)

        # Determine cloud/server jira
        self.users_type = 'accountId' if issues['issues'][0]['fields']['reporter'].get(
            'accountId') else 'name'

        for issue in issues['issues']:
            user = str(issue['fields']['reporter']['displayName']
                      ) + ' ~ ' + issue['fields']['reporter'][self.users_type]
            self.users.add(user)
            if self._has_field(issue['fields'], 'assignee'):
                user = str(issue['fields']['assignee']['displayName']
                          ) + ' ~ ' + issue['fields']['assignee'][self.users_type]
            self.users.add(user)

        return sorted(self.users)

    def get_current_user(self, role):
        query = role + ' = currentUser()'
        issues = self.jira.search_issues(
            query, fields=role, json_result='True', maxResults=-1)

        issue = issues['issues'][0]['fields']
        if self._has_field(issue, role):
            return issue[role][self.users_type]

    def load_project_config(self, repo):
        '''
        Load project configuration for the current git repo
        The current repo can either be determined by current files path
        or by the user setting g:vira_repo (part of :ViraLoadProject)

        For example, an entry in projects.yaml may be:

        vira:
          server: https://jira.tgall.ca
          project_name: VIRA
        '''

        # Only proceed if projects file parsed successfully
        if not getattr(self, 'vira_projects', None):
            return

        # If current repo/folder doesn't exist, use __default__ project config if it exists
        if repo == '':
            repo = run_command('git rev-parse --show-toplevel')['stdout'].strip()
            if not self.vira_projects.get(repo):
                repo = repo.split('/')[-1]
            if not self.vira_projects.get(repo):
                repo = run_command('pwd')['stdout'].strip()
            if not self.vira_projects.get(repo):
                repo = repo.split('/')[-1]
            if not self.vira_projects.get(repo):
                repo = '__default__'
                if not self.vira_projects.get('__default__'):
                    return

        # Set server
        server = self.vira_projects.get(repo, {}).get('server')
        if server:
            vim.command(f'let g:vira_serv = "{server}"')

        # Set user-defined filters for current project
        #  for issue in self.vira_db.execute('SELECT * FROM ' + vira_table):
            #  self.vira_db.insert(issue)

        # Set user-defined filters for current project
        for key in self.userconfig_filter.keys():
            value = self.vira_projects.get(repo, {}).get('filter', {}).get(key)
            if value:
                self.userconfig_filter[key] = value
        print(str(self.vira_projects.get(repo, {}).get('filter', {}).get('project', {})))

        # Set user-defined new-issue defaults for current project
        for key in self.userconfig_newissue.keys():
            value = self.vira_projects.get(repo, {}).get('newissue', {}).get(key)
            if value:
                self.userconfig_newissue[key] = value

        # Set user-defined issue sort options
        sort_order = self.vira_projects.get(repo, {}).get('issuesort', 'updated DESC')
        self.userconfig_issuesort = ', '.join(sort_order) if type(
            sort_order) == list else sort_order

    def print_projects(self):
        '''
        Build a vim pop-up menu for a list of projects
        '''

        all_projects = self.get_projects()
        batch_size = 10
        project_batches = [all_projects[i:i + batch_size]
                           for i in range(0, len(all_projects), batch_size)]

        for batch in project_batches:
            projects = self.jira.createmeta(
                projectKeys=','.join(batch), expand='projects')['projects']
            [print(p['key'] + ' ~ ' + p['name']) for p in projects]

    def print_users(self):
        '''
        Print users
        '''

        current_user = \
            self.get_current_user('assignee') or \
            self.get_current_user('reporter')
        if current_user:
            print(current_user + ' ~ currentUser')

        for user in self.users:
            print(user)
        print('Unassigned')

    def query_issues(self):
        '''
        Query issues based on current filters
        '''

        q = []
        for filterType in self.userconfig_filter.keys():
            filter_str = self.filter_str(filterType)
            if filter_str:
                q.append(filter_str)

        query = ' AND '.join(q) + ' ORDER BY ' + self.userconfig_issuesort
        issues = self.jira.search_issues(
            query,
            #  fields='updated,created,fixVersions,summary,comment,status,statusCategory,issuetype,assignee,reporter',
            fields='summary,comment,status,statusCategory,issuetype,assignee',
            json_result='True',
            maxResults=vim.eval('g:vira_issue_limit'))

        return issues['issues']

    def report_users(self, report):
        '''
        Replace report accountid with names
        '''

        for user in self.users:
            user = user.split(' ~ ')
            if user[0] != "Unassigned":
                report = report.replace('accountid:', '').replace(
                    '[~' + user[1] + ']', '[~' + user[0] + ']')

        return report

    def reset_filters(self):
        '''
        Reset filters to their default values
        '''

        self.userconfig_filter = dict(self.userconfig_filter_default)

    def set_report_lines(self, report, description, issue):
        '''
        Create dictionary for vira report that shows relationship
        between line numbers and fields to be edited
        '''

        writable_fields = {
            'Assignee': 'ViraSetAssignee',
            'Component': 'ViraSetComponent',
            'Priority': 'ViraSetPriority',
            'Epic Link': 'ViraSetEpic',
            'Status': 'ViraSetStatus',
            'Type': 'ViraSetType',
            'Version': 'ViraSetVersion',
        }

        self.report_lines = {}

        for idx, line in enumerate(report.split('\n')):
            for field, command in writable_fields.items():
                if field in line:
                    self.report_lines[idx + 1] = command
                    continue

        for x in range(16, 21):
            self.report_lines[x] = 'ViraEditSummary'

        description_len = description.count('\n') + 3
        for x in range(21, 23 + description_len):
            self.report_lines[x] = 'ViraEditDescription'

        offset = 2 if len(issue['comment']['comments']) > 4 else 1
        comment_line = 25 + description_len + offset
        for comment in issue['comment']['comments']:
            comment_len = comment['body'].count('\n') + 3
            for x in range(comment_line, comment_line + comment_len):
                self.report_lines[x] = 'ViraEditComment ' + comment['id']
            comment_line = comment_line + comment_len

    def set_prompt_text(self):
        '''
        Take the user prompt text and perform an action
        Usually, this involves writing to the jira server
        '''

        # User input
        issue = vim.eval('g:vira_active_issue')
        userinput = vim.eval('g:vira_input_text')
        input_stripped = userinput.replace(self.prompt_text_commented.strip(), '').strip()

        # Check if anything was actually entered by user
        if input_stripped == '' or userinput.strip() == self.prompt_text.strip():
            print("No vira actions performed")
            return

        if self.prompt_type == 'edit_filter':
            self.userconfig_filter = json.loads(input_stripped)
        elif self.prompt_type == 'add_comment':
            self.jira.add_comment(issue, input_stripped)
        elif self.prompt_type == 'edit_comment':
            self.active_comment.update(body=input_stripped)
        elif self.prompt_type == 'summary':
            self.jira.issue(issue).update(summary=input_stripped)
        elif self.prompt_type == 'description':
            self.jira.issue(issue).update(description=input_stripped)
        elif self.prompt_type == 'issue':
            self.create_issue(input_stripped)

    def versions_hide(self, state):
        '''
        Display and hide complete versions
        '''

        if state is True or 1 or 'ture' or 'True':
            self.version_hide = True
        elif state is False or 0 or 'false' or 'False':
            self.version_hide = False
        else:
            self.version_hide = not self.version_hide

    def version_percent(self, project, fixVersion):
        '''
        Initialize vira
        '''
        if self.ViraDB.jql_start_at is not None:
            if str(project) != '[]' and str(project) != '' and str(fixVersion) != '[]' and str(fixVersion) != '':
                name = str(fixVersion)
                try:
                    self.ViraDB.db_connect('TRUE')
                    project = self.ViraDB.select_project(str(project))
                    try:
                        fixVersion = str(self.ViraDB.select_version(str(project[0]), fixVersion)[2])
                    except:
                        fixVersion = str(self.ViraDB.select_version(str(project[0]), fixVersion[2])[2])
                        pass
                    #  total = self.ViraDB.count_issue_version(str(project[2]), fixVersion)
                    fixed = self.ViraDB.count_issue_version_status(str(project[2]), fixVersion, 'Done')
                    self.ViraDB.db_connect('FALSE')
                    total = fixed[0]
                    fixed = fixed[1]
                    percent = str(round(fixed / total * 100, 1)) if fixed != 0 else 1
                    space = ''.join([char * (5 - len(percent)) for char in ' '])

                    try:
                        description = str(fixVersion[3])
                    except:
                        description = 'None'
                        pass

                except:
                    total = 0
                    pending = 0
                    fixed = total - pending
                    percent = "0"
                    space = ''.join([char * (5 - len(percent)) for char in ' '])
                    description = 'None'
                    pass

                version = str(
                    str(name) + ' ~ ' + str(description) + '|' + str(fixed) + '/' + str(total) +
                    space + '|' + str(percent) + '%')

            else:
                percent = 0

            return percent
