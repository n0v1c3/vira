#!/usr/bin/env python
'''
Database functionctions for vira
'''

#  TODO: VIRA-253 [210319] - Create summary `db` with id links
#  TODO: VIRA-253 [210326] - Check VIRA versions and `update`/`cleanup` db is required
#  TODO: VIRA-253 [210326] - If there is a real update print a message
#  - Should show only `issue_id` and `field` that has been updated
#  - This should be fine with a planed timer and sync with the jql search
#  - Using it to confirm right now
#  TODO: VIRA-253 [210424] - This could be version or db usage overload
# - We will miss a user if we get here
#  TODO: VIRA-253 [210505] - Percent complete for issues with no versions goes here
#  TODO: VIRA-253 [210511] - `nvim` will require a handle for print and sql at the same time
#  TODO: VIRA-253 [210511] - `jql_offset` currently used to keep queries moving
#  TODO: VIRA-253 [210511] - Hold `jql_offset` in `db` for `update_jql`

from datetime import datetime
import vim
import sqlite3
from sqlite3 import Error

class ViraDB():
    '''
    Vira DB conection control and data management
    '''
    def __init__(self, file_db=vim.eval('g:vira_config_file_db')):
        '''
        Initialize Vira DB
        '''

        file_db = str(file_db)

        vim.command('let g:vira_config_file_db = "' + file_db + '"')

        self.vira_db = file_db
        self.db_serv = []
        self.updated_date = 0
        self.update_issues = []
        self.last_issues = []
        self.jql_start_at = None
        self.jql_offset = 0
        self.con_status = "False"
        self.con = None
        self.cur = None
        self.lastrowid = 0
        pass

    def _get_serv(self):
        '''
        Current server hostname name
        '''

        return str(self.db_serv[1])

    def format_date(self, date):
        '''
        Clean date formate
        '''

        time = datetime.now().strptime(date, '%Y-%m-%dT%H:%M:%S.%f%z').astimezone()
        return str(time)[0:10] + ' ' + str(time)[11:19]

    def create(self, table):
        '''
        Create the database file in the vira dir
        '''

        table = str(table)

        try:
            self.cur.execute(
                'CREATE TABLE vira' +
                '(' +
                'version TEXT,' +
                'description TEXT' +
                ')'
            )
            self.cur.execute(
                'CREATE TABLE comments' +
                '(' +
                'issue_id INTEGER,' +
                'idx INTEGER,' +
                'author TEXT,' +
                'date TEXT,' +
                'body TEXT,' +
                'UNIQUE(issue_id, idx)' +
                ')'
            )
            self.cur.execute(
                'CREATE TABLE issues' +
                '(' +
                'idx INTEGER PRIMARY KEY NOT NULL,' +
                'project_id INTEGER,' +
                'version_id INTEGER,' +
                'key INTEGER,' +            # <- This is the KEY of the issue ie "VIRA-253" would be 253 here.
                'summary TEXT,' +
                'status_id INTEGER,' +
                'created INTEGER,' +
                'updated INTEGER,' +
                'UNIQUE(project_id, version_id, key)'
                ')'
            )
            self.cur.execute(
                'CREATE TABLE projects' +
                '(' +
                'server_id INTEGER,' +
                'name TEXT,' +
                'description TEXT' +
                ')'
            )
            self.cur.execute(
                'CREATE TABLE servers' +
                '(' +
                'name TEXT,' +
                'description TEXT,' +
                'address TEXT,' +
                'jql_start_at INTEGER,' +
                'jql_offset INTEGER' +
                ')'
            )
            self.cur.execute(
                'CREATE TABLE statuses' +
                '(' +
                'project_id INTEGER,' +
                'name TEXT,' +
                'description TEXT' +
                ')'
            )
            self.cur.execute(
                'CREATE TABLE summaries' +
                '(' +
                'issue_id INTEGER,' +
                'user_id INTEGER,' +
                'description TEXT,' +
                'date INTEGER' +
                ')'
            )
            self.cur.execute(
                'CREATE TABLE types' +
                '('
                'idx INTEGER PRIMARY KEY NOT NULL,' +
                'project_id INTEGER,' +
                'name TEXT,' +
                'UNIQUE(project_id, name)' +
                ')'
            )
            self.cur.execute(
                'CREATE TABLE users' +
                '(' +
                'idx INTEGER PRIMARY KEY NOT NULL,' +
                'server_id INTEGER,' +
                'name TEXT,' +
                'jira_id TEXT,' +
                'UNIQUE(idx, server_id, jira_id)' +
                ')'
            )
            self.cur.execute(
                'CREATE TABLE versions' +
                '(' +
                'idx INTEGER PRIMARY KEY NOT NULL,' +
                'project_id INTEGER,' +
                'name TEXT,' +
                'description TEXT,' +
                'UNIQUE(idx, project_id)' +
                ')'
            )
            self.insert_vira()

        except:
            pass

    def connect(self, server):
        '''
        Connection initialization `vira_api`
        '''

        server = str(server)
        vim.command('let g:vira_serv = "' + server + '"')
        try:
            self.db_serv = self.select_server(server)
            if self.db_serv is None:
                self.db_serv = self.insert_server(server)
        except:
            try:
                self.create('')
                self.db_serv = self.insert_server(server)
            except:
                self.connect(server)
        self.jql_start_at = self.db_serv[4]

    def update_server(self):
        try:
            jql_start_at = str(self.jql_start_at)
            name = "'" + str(self._get_serv()) + "'"
            self.cur.execute("UPDATE servers SET jql_start_at=" + jql_start_at + " WHERE name IS " + name)
        except Error as e:
            print(e)
            raise e
        row = self.select_server()
        return row

    def jql_issue(self, issue):
        key = str(issue['key'])

        issue_count = key.split('-')[1]

        project = key.replace('-', '')
        project = "".join(filter(lambda x: not x.isdigit(), project))

        issueType = str(issue['fields']['issuetype']['name'])

        summary = str(issue['fields']['summary'])

        comments = list()
        idx = 0
        for idx, comment in enumerate((issue['fields']['comment']['comments'])):
            comments.append([project, issue_count, idx, str(comment['author']['displayName']), str(self.format_date(comment['updated'])), str(comment['body'])])

        try:
            version = 'None'
            version_description = 'No Description'

            for versions in self.update_issues[int(self.jql_offset)]['fields']['fixVersions']:
                version = str(versions['name'])
                version_description = str(versions['description']) if str(versions['description']) != '' else 'No Description'
        except:
            version = 'None'
            version_description = 'Issues that have not been assigned to any ' + str(project) + ' versions.'
            pass

        status = str(issue['fields']['status']['statusCategory']['name'])

        created = str(issue['fields']['created'])
        created = str(datetime.now(
        ).strptime(created, '%Y-%m-%dT%H:%M:%S.%f%z').astimezone(
        ))
        created = str(created).replace(' ', '').replace('-', '').replace(':', '')
        created = str(created)[0:15]

        updated = str(issue['fields']['updated'])
        self.updated_date = str(datetime.now().strptime(str(issue['fields']['updated']), '%Y-%m-%dT%H:%M:%S.%f%z').astimezone())
        updated = str(self.updated_date).replace(' ', '').replace('-', '').replace(':', '')
        updated = str(updated)[0:15]

        try:
            user_name = str(issue['fields']['reporter']['name'])
            user_displayName = str(issue['fields']['reporter']['displayName'])
        except:
            pass
        try:
            if 'assignee' in issue['fields'] and type(issue['fields']['assignee']) == dict:
                user_name = str(issue['fields']['assignee']['name'])
                user_displayName = str(issue['fields']['assignee']['displayName'])
        except:
            pass

        self.insert_issue(str(project), str(version), str(version_description), str(issue_count), str(issueType), str(summary), str(status), str(created), str(updated), [str(user_name), str(user_displayName)], comments)

    def safe_string(self, string):
        string = string.replace("'", "''")
        return string

    def insert_vira(self):
        try:
            self.cur.execute('INSERT INTO vira(version,description) VALUES (?,?)',
                             (str(vim.eval('s:vira_version')),
                              str('Stay inside vim while following and updating Jira issues along with creating new issues on the go.')))
        except Error as e:
            print(e)
            raise e

    def update_jql(self, jira):
        '''
        Query issues based on current filters
        '''
        #  updated_date = str(self.updated_date)
        #  updated_date = '"' + updated_date + '"' if updated_date != str(0) else updated_date
        self.jql_start_at = self.jql_start_at if self.jql_offset >= int(0) and self.jql_offset < int(vim.eval('g:vira_jql_max_results')) else self.jql_start_at + 1
        self.jql_offset = self.jql_offset + 1 if self.jql_offset > int(0) and self.jql_offset < int(vim.eval('g:vira_jql_max_results')) else 0
        #  print('jql_start_at: ' + str(self.jql_start_at) + ' jql_offset:' + str(self.jql_offset))
        try:
            issues = jira.search_issues(
                'updatedDate >= 0 ORDER BY updatedDate ASC',
                fields='project,updated,created,fixVersions,summary,comment,status,statusCategory,issuetype,assignee,reporter',
                json_result='True',
                startAt=int(vim.eval('g:vira_jql_max_results')) * self.jql_start_at + (self.jql_offset),
                maxResults=vim.eval('g:vira_jql_max_results'))
        except:
            raise Error

        return issues['issues']

    def select_vira(self):
        try:
            self.cur.execute('SELECT rowid,* FROM vira WHERE rowid=?', (1,))
            row = self.cur.fetchone()
        except Error as e:
            print(e)
            raise e

        return row

    def insert_server(self, name):
        '''
        Update server details in the database as required
        '''
        try:
            name = str(name)
            self.cur.execute('INSERT INTO servers(name, description, jql_start_at) VALUES (?,?,?)', (str(name), str(name), str(0)))
        except Error as e:
            print(e)
            raise e

        return self.select_server(str(name))

    def select_server(self, name):
        '''
        Select current server `rowid`
        '''
        try:
            name = str(name)
            self.cur.execute('SELECT rowid, * FROM servers WHERE name IS ?', (name,))
            row = self.cur.fetchone()
        except Error as e:
            print(e)
            raise e

        return row

    def insert_comment(self, lastrowid, project, issue_id, idx, author, date, body):
        '''
        Update server details in the databas as required
        '''
        body = str(body)
        author = str(author)
        date = str(date)
        idx = str(idx)

        try:
            # Update `project db row`
            rowid = str(self.select_comment(project, issue_id, idx)[0])
            self.cur.execute(
                'UPDATE comments SET body=?, date=? WHERE rowid=? AND idx=?',
                (body, date, rowid, idx)
            )
        except:
            try:
                self.cur.execute('INSERT OR REPLACE INTO comments(issue_id,idx,author,date,body) ' +
                                 'VALUES (?,?,?,?,?)',
                                 (str(issue_id), idx, str(author), str(date), str(body)), )
            except Error as e:
                raise e
            pass

    def select_comment(self, issue_id, idx):
        '''
        Select current server `rowid`
        '''
        try:
            self.con.execute(
                'SELECT rowid,* FROM comments WHERE issue_id=? AND idx=?',
                (str(issue_id), str(idx), )
            )
            row = self.con.fetchone()
        except:
            raise Error
        return row

    def insert_project(self, project):
        '''
        Update server details in the databas as required
        '''

        project = str(project)
        try:
            project_id = str(self.select_project(project)[0])
            self.cur.execute('UPDATE projects SET description=? WHERE rowid = ?', (project, project_id, ))
        except:
            self.cur.execute('INSERT OR REPLACE INTO projects(server_id,name,description) VALUES (?,?,?)', (
                str(self.db_serv[0]), project, project, ))
            pass

        return self.select_project(project)

    def select_project(self, project):
        '''
        Select current server `rowid`
        '''
        try:
            self.cur.execute('SELECT rowid,* FROM projects WHERE server_id=? AND name IS ?', (str(self.db_serv[0]), str(project)))
            row = self.cur.fetchone()
        except Error as e:
            print(e)
            raise e

        return row

    def insert_version(self, project_id, version, description):
        '''
        Update server details in the databas as required
        '''
        project_id = str(project_id)
        version = str(version)
        description = str(description)
        try:
            version_id = str(self.select_version(str(project_id), str(version))[0])
            self.cur.execute('UPDATE versions SET name = ?, description = ? WHERE idx = ?', (str(version), str(description), version_id, ))
        except:
            try:
                self.cur.execute('INSERT OR REPLACE INTO versions(project_id, name, description) ' +
                                 'VALUES(?,?,?)', (project_id, version, description, ))
            except:
                pass
            pass

        return self.select_version(project_id, version)

    def select_version(self, project_id, name):
        '''
        Select current server `rowid`
        '''
        try:
            project_id = str(project_id)
            name = str(name)
            self.cur.execute('SELECT rowid,* FROM versions WHERE project_id=? AND name IS ?', (project_id, name, ))
            row = self.cur.fetchone()
        except Error as e:
            print(e)
            pass
        return row

    def select_versions(self):
        versions = set()
        try:
            self.cur.execute(
                'SELECT * FROM issues ' +
                'LEFT JOIN projects ON projects.rowid = issues.project_id ' +
                'LEFT JOIN versions ON versions.rowid = issues.version_id ' +
                'WHERE projects.server_id = ? ' +
                'GROUP BY issues.version_id, issues.project_id ',
                (str(self.db_serv[0]), )
            )
            issues = self.cur.fetchall()
            for issue in issues:
                version = str(issue[12])
                description = str(issue[13])
                project = str(issue[9])
                try:
                    fixed = self.count_issue_version_status(str(project), str(version), 'Done')
                except:
                    description = str('Unassigned')
                    fixed = ['1', '0']
                    pass
                percent = str(round(int(str(fixed[1])) / int(str(fixed[0])) * 100, 1)) if int(str(fixed[0])) != 0 else 1
                versions.add(tuple([project, version, description, percent]))

        except Error as e:
            print(e)
            raise e

        return versions

    def insert_status(self, project, status, description):
        '''
        Update server details in the databas as required
        '''
        try:
            # Confirm `project db row` exists
            try:
                project_id = self.select_project(str(project))[0]
            except:
                project_id = project
                pass

            try:
                status_id = str(self.select_status(str(project_id), str(status))[0])
                self.cur.execute('UPDATE statuses SET description=? WHERE rowid=? AND project_id=?', (str(description), str(status_id), str(project_id), ))
            except:
                self.cur.execute('INSERT OR REPLACE INTO statuses(project_id,name,description) VALUES (?,?,?)', (
                    str(project_id), str(status), str(description), ))
                pass
        except:
            pass

        return self.select_status(project, status)

    def select_status(self, project, status):
        '''
        Select current server `rowid`
        '''
        try:
            self.cur.execute('SELECT rowid,* FROM statuses WHERE project_id=? AND name IS ?', (str(project), str(status), ))
            row = self.cur.fetchone()
        except Error as e:
            print(e)
            raise e
        return row

    def insert_type(self, project_id, name):
        '''
        Update server details in the databas as required
        '''
        name = str(name)
        project_id = str(project_id)
        try:
            idx = str(self.select_type(project_id, name)[0])
            self.cur.execute('UPDATE types SET name=? WHERE idx=?', (name, idx, ))
            #  print('UPDATE types SET name=' + name + ' WHERE rowid=' + rowid)
        except:
            self.cur.execute(
                'INSERT OR REPLACE INTO types (project_id,name) VALUES (?,?)',
                (project_id, name, )
            )
            #  print('INSERT OR REPLACE INTO types (project_id,name) VALUES (' + project_id + ',' + name + ')')
            pass

    def select_type(self, project_id, name):
        '''
        Select current type `rowid`
        '''
        try:
            self.cur.execute(
                'SELECT rowid,* FROM types WHERE project_id=? AND name IS ?',
                (project_id, name, )
            )
            row = self.cur.fetchone()
        except Error as e:
            print(e)
            raise e
        return row

    def insert_user(self, name, jira_id):
        '''
        Update server details in the databas as required
        '''
        name = str(name)
        jira_id = str(jira_id)
        try:
            user_id = str(self.select_user(str(jira_id))[0])
            self.cur.execute(
                'UPDATE users SET name=? WHERE server_id=? AND jira_id IS ? AND rowid=?',
                (str(name), str(self.db_serv[0]), str(jira_id), str(user_id), )
            )
        except:
            self.cur.execute('INSERT OR REPLACE INTO users(server_id, name, jira_id) ' +
                             'VALUES(?,?,?)', (self.db_serv[0], name, jira_id, ))
        return self.select_user(jira_id)

    def select_user(self, jira_id):
        '''
        Select current server `rowid`
        '''
        try:
            server_id = self.db_serv[0]
            self.cur.execute(
                'SELECT rowid,* FROM users WHERE server_id=? AND jira_id IS ?',
                (str(server_id), str(jira_id), )
            )
            row = self.cur.fetchone()
        except Error as e:
            print(e)
        return row

    def insert_issue(self, project, version, version_description, key, issueType, summary, status, created, updated, user, comments):
        '''
        Create or update an issue
        :param con:
        :param issue:
        :return:
        '''
        project = str(project)
        summary = str(summary)
        updated = str(updated)
        user_displayName = str(user[0])
        user_name = str(user[1])
        version = str(version)
        version_description = str(version_description)

        self.insert_user(user_displayName, user_name)
        project_id = str(self.insert_project(str(project))[0])

        if str(version) != 'None':
            try:
                version_id = str(self.insert_version(project_id, version, version_description)[0])
                #  print('VIRA: Version ' + str(version) + ', has been added to the ' + str(project) + ' project on ' + str(self.db_serv[1]) + '!')
            except:
                version_id = 0
        else:
            version_id = 0

        self.insert_type(str(project_id), str(issueType))
        status_id = self.insert_status(str(project_id), str(status), str(str(status) + ' - Description'))[0]

        try:
            issue = self.select_issue(str(project_id), str(key))
            self.cur.execute(
                'UPDATE issues SET summary=?, status_id=? WHERE updated < ? AND project_id=? AND idx=?',
                (str(summary), str(status_id), updated, str(project_id), str(issue[0]), )
            )
            #  if int(issue[7]) < int(updated):
                #  print('Issue updated on ' + str(self._get_serv()) + ' - ' + str(project) + '-' + str(key) + ': ' + str(summary) + ' | ' + str(status) + ' ~ ' + str(updated))
        except:
            self.cur.execute(
                'INSERT INTO issues(project_id,version_id,key,summary,status_id,created,updated) VALUES(?,?,?,?,?,?,?)',
                (str(project_id), str(version_id), str(key), str(summary), str(status_id), str(created), updated, )
            )
                #  print('New issue added to ' + str(self._get_serv()) + ' - ' + str(project) + '-' + str(key) + ': ' + str(summary) + ' | ' + str(status) + ' ~ ' + str(updated))
            pass

        try:
            for comment in range(len(comments)):
                project = str(comments[comment][0])
                issue_id = str(comments[comment][1])
                idx = str(comments[comment][2])
                author = str(comments[comment][3])
                update = str(comments[comment][4])
                body = str(comments[comment][5])
                #  print(project + '-' + issue_id + ': ' + idx + ' ' + author + ' (' + update + ') - ' + body)
                self.insert_comment(issue_id, project, issue_id, idx, author, update, body)
        except:
            pass

    def select_issue(self, project, key):
        '''
        Select current server `rowid`
        '''
        try:
            self.cur.execute('SELECT rowid,* FROM issues WHERE project_id=? AND key=?', (str(project), str(key), ))
            row = self.cur.fetchone()
        except Error as e:
            raise e
        return row

    def count_issue_version(self, project, version):
        '''
        Select current server `rowid`
        '''

        try:
            project_id = self.select_project(str(project))[0]
            version_id = self.select_version(str(project_id), str(version))[0]
            self.cur.execute('SELECT COUNT(*) FROM issues WHERE project_id=? AND version_id=?', (str(project_id), str(version_id), ))
            #  self.cur.execute('SELECT COUNT(*) FROM issues WHERE project_id IS "' + str(project_id) + '" AND version_id IS "' + str(version_id) + '"')
            count = self.cur.fetchone()
        except Error as e:
            raise e
        return int(count[0])

    def count_issue_version_status(self, project, version, status):
        '''
        Select current server `rowid`
        '''

        count = []
        try:
            project_id = self.select_project(str(project))[0]
            version_id = self.select_version(str(project_id), str(version))[0]
            status_id = self.select_status(str(project_id), str(status))[0]
            self.cur.execute('SELECT COUNT(*) FROM issues WHERE project_id=? AND version_id=?', (str(project_id), str(version_id), ))
            count.append(int(str(self.cur.fetchone()[0])))
            self.cur.execute('SELECT COUNT(*) FROM issues WHERE project_id=? AND version_id=? AND status_id=?', (str(project_id), str(version_id), str(status_id), ))
            count.append(int(str(self.cur.fetchone()[0])))
        except Error as e:
            print(e)
            pass
        return count

    def db_connect(self, status):
        '''
        Set status of the db connection
        '''

        if status.upper() != "TRUE":
            try:
                self.con.commit()
                self.con.close()
                self.con_status = "False"
            except Error as e:
                print(e)
        else:
            try:
                self.con = sqlite3.connect(self.vira_db)
                self.cur = self.con.cursor()
                self.con_status = "True"
            except Error as e:
                print(e)

    def latest_issue(self):
        '''
        Select current server `rowid`
        '''
        try:
            self.cur.execute(
                'SELECT *,servers.name FROM issues ' +
                'INNER JOIN projects ON projects.rowid = issues.project_id ' +
                'INNER JOIN servers ON servers.rowid = projects.server_id ' +
                'WHERE servers.name=? ' +
                'ORDER BY ' +
                'issues.rowid DESC, ' +
                'issues.updated DESC ' +
                'LIMIT 1', (str(self._get_serv()), )
            )
            row = self.cur.fetchone()
        except Error as e:
            print(e)
            pass
        return row

    def last_update(self, host_name):
        '''
        Last update round
        '''

        return self.select_server(host_name)[4]

def __main__(self, file_db=vim.eval('g:vira_config_file_db')):
    pass
