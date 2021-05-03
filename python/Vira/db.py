#!/usr/bin/env python
'''
Database functionctions for vira
'''

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
        self.jql_start_at = 0
        self.jql_offset = 0
        pass

    def _get_serv(self):
        return str(vim.eval('g:vira_serv'))

    def query(self, query):
        try:
            con = sqlite3.connect(self.vira_db)
            rows = con.cursor().execute(query).fetchall()
            con.commit().close()
        except:
            raise Error
        return rows

    def create(self, table):
        '''
        Create the database file in the vira dir
        '''

        table = str(table)

        try:
            con = sqlite3.connect(self.vira_db)
            cur = con.cursor()
            if table is 'issue':
                self.updated_date = 0
                self.update_issues = []
                self.last_issues = []
                vim.command('let g:vira_async_sleep = 0')
                vim.command('let g:vira_updated_issue = ""')
                try:
                    cur.execute('DROP TABLE ' + table + 's')
                except:
                    pass
                cur.execute("CREATE TABLE " + table + "s (project_id int, version_id int, identifier int, summary text, status_id int, created int, updated int)")
                self.update_server()
            else:
                #  TODO: VIRA-253 [210326] - Check VIRA versions and `update`/`cleanup` db is required
                cur.execute("CREATE TABLE vira (version text, description text)")

                cur.execute("CREATE TABLE issues (project_id int, version_id int, identifier int, summary text, status_id int, created int, updated int)")
                cur.execute("CREATE TABLE projects (server_id int, name text, description text)")
                cur.execute("CREATE TABLE servers (name text, description text, address text, jql_start_at int, jql_offset int)")
                cur.execute("CREATE TABLE statuses (project_id int, name text, description text)")
                #  cur.execute("CREATE TABLE todos (issue_id int, user_id int, description text, filename text, date int)")
                #  cur.execute("CREATE TABLE comments (issue_id int, user_id int, count int, description text, date int)")
                #  cur.execute("CREATE TABLE summaries (issue_id int, user_id int, description text, date int)")
                cur.execute("CREATE TABLE types (project_id int, name text)")
                cur.execute("CREATE TABLE users (server_id int, name text, jira_id text)")
                cur.execute("CREATE TABLE versions (project_id int, name text, description text)")

                self.insert_vira()

            con.commit()
            con.close()
        except:
            pass

    def connect(self, server):
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
            except Error as e:
                self.connect(server)
            except OSError as e:
                raise e
            pass
        self.jql_start_at = self.db_serv[4]

    def update_server(self):
        try:
            con = sqlite3.connect(self.vira_db)
            cur = con.cursor()
            jql_start_at = str(self.jql_start_at)
            name = "'" + str(self.safe_string(self._get_serv())) + "'"
            cur.execute("UPDATE servers SET jql_start_at=" + jql_start_at + " WHERE name IS " + name)
            con.commit()
            con.close()
        except Error as e:
            print(e)
            raise e

        return self.select_server()

    def update_issue(self, issue):
        key = str(issue['key'])

        issue_count = key.split('-')[1]

        project = key.replace('-', '')
        project = "".join(filter(lambda x: not x.isdigit(), project))

        issueType = str(issue['fields']['issuetype']['name'])

        summary = str(issue['fields']['summary'])

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
        created = str(created)[0:19]

        updated = str(issue['fields']['updated'])
        self.updated_date = str(datetime.now().strptime(str(issue['fields']['updated']), '%Y-%m-%dT%H:%M:%S.%f%z').astimezone())[0:16]
        updated = str(self.updated_date).replace(' ', '').replace('-', '').replace(':', '')
        #  self.update_server(updated)

        try:
            user_name = str(issue['fields']['reporter']['name'])
            user_displayName = str(issue['fields']['reporter']['displayName'])

            self.insert_user(user_displayName, user_name)
        except:
            pass
        try:
            if 'assignee' in issue['fields'] and type(issue['fields']['assignee']) == dict:
                user_name = str(issue['fields']['assignee']['name'])
                user_displayName = str(issue['fields']['assignee']['displayName'])
                self.insert_user(user_displayName, user_name)
        except:
            pass

        #  vim.command('echo "' + str(key) + ' - ' + str(version) + ' - ' + str(summary) + '"')
        self.insert_issue(str(project), str(version), str(version_description), str(issue_count), str(issueType), str(summary), str(status), str(created), str(updated))

    def safe_string(self, string):
        string = string.replace("'", "''")
        return string

    def insert_vira(self):
        try:
            con = sqlite3.connect(self.vira_db)
            cur = con.cursor()
            cur.execute('INSERT INTO vira(version,description) VALUES (?,?)',
                        (str(vim.eval('s:vira_version')),
                         str('Stay inside vim while following and updating Jira issues along with creating new issues on the go.')))
            con.commit()
            con.close()
        except Error as e:
            print(e)
            raise e

        return self.select_vira()

    def update_jql(self, jira):
        '''
        Query issues based on current filters
        '''
        #  updated_date = str(self.updated_date)
        #  updated_date = '"' + updated_date + '"' if updated_date != str(0) else updated_date
        try:
            issues = jira.search_issues(
                'updatedDate >= 0 ORDER BY updatedDate ASC',
                fields='project,updated,created,fixVersions,summary,comment,status,statusCategory,issuetype,assignee,reporter',
                json_result='True',
                startAt=int(vim.eval('g:vira_jql_max_results')) * self.jql_start_at,
                maxResults=vim.eval('g:vira_jql_max_results'))
        except:
            raise Error
        return issues['issues']

    def select_vira(self):
        try:
            con = sqlite3.connect(self.vira_db)
            cur = con.cursor()
            cur.execute('SELECT rowid, * FROM vira WHERE rowid=?', (1,))
            row = cur.fetchone()
            con.commit()
            con.close()
        except Error as e:
            print(e)
            raise e

        return row

    def insert_server(self, name):
        '''
        Update server details in the database as required
        '''
        try:
            con = sqlite3.connect(self.vira_db)
            cur = con.cursor()
            name = str(self.safe_string(name))
            cur.execute('INSERT INTO servers(name, description, jql_start_at) VALUES (?,?,?)', (str(name), str(name), str(0)))
            con.commit()
            con.close()
        except Error as e:
            print(e)
            raise e

        return self.select_server(str(name))

    def select_server(self, name):
        '''
        Select current server `rowid`
        '''
        try:
            con = sqlite3.connect(self.vira_db)
            cur = con.cursor()
            name = str(self.safe_string(name))
            cur.execute('SELECT rowid, * FROM servers WHERE name IS ?', (name,))
            row = cur.fetchone()
            con.commit()
            con.close()
        except Error as e:
            print(e)
            raise e

        return row

    def insert_project(self, project):
        '''
        Update server details in the databas as required
        '''
        try:
            con = sqlite3.connect(self.vira_db)
            cur = con.cursor()
            try:
                # Confirm `project db row` exists
                project_id = str(self.select_project(str(project))[0])

                # Update `project db row`
                cur.execute("UPDATE projects SET description = '" + str(project) + "' WHERE rowid = " + project_id)
            except:
                try:
                    cur.execute('INSERT OR REPLACE INTO projects(server_id,name,description) VALUES (?,?,?)', (
                        str(self.db_serv[0]), str(project), str(project)))
                except Error as e:
                    print(e)
                    raise e
                pass
            con.commit()
            con.close()
        except:
            pass

        return self.select_project(project)

    def select_project(self, project):
        '''
        Select current server `rowid`
        '''
        try:
            con = sqlite3.connect(self.vira_db)
            cur = con.cursor()
            cur.execute('SELECT rowid, * FROM projects WHERE server_id=' + str(self.db_serv[0]) + ' AND name IS "' + str(project) + '"')
            row = cur.fetchone()
            con.commit()
            con.close()
        except Error as e:
            print(e)
            raise e

        return row

    def insert_version(self, project_id, version, description):
        '''
        Update server details in the databas as required
        '''
        try:
            con = sqlite3.connect(self.vira_db)
            cur = con.cursor()
            try:
                version_id = str(self.select_version(str(project_id), str(version))[0])

                # Update `project db row`
                cur.execute("UPDATE versions SET name = '" + str(version) + "', description = '" + str(description) + "' WHERE rowid = " + version_id)
            except:
                try:
                    cur.execute('INSERT OR REPLACE INTO versions(project_id,name,description) VALUES (?,?,?)', (
                        str(project_id), str(version), str(description)))
                except:
                    pass
                pass
            con.commit()
            con.close()
        except:
            pass

        return self.select_version(project_id, version)

    def select_version(self, project_id, name):
        '''
        Select current server `rowid`
        '''
        try:
            con = sqlite3.connect(self.vira_db)
            cur = con.cursor()
            cur.execute('SELECT rowid, * FROM versions WHERE project_id=' + str(project_id) + ' AND name IS "' + str(name) + '"')
            row = cur.fetchone()
            con.commit()
            con.close()
        except Error as e:
            #  print(e)
            raise e
        return row

    def order_by(self, orders):
        order_list = str()
        for order in orders:
            order_list = str(order_list) + str(('ORDER BY' if len(order_list) == 0 else ',') + ' ' +
                                               str(order[0]) + '.' + # table
                                               str(order[1]) + ' ' + # column
                                               str(order[2]))        # sort
        return str(order_list)

    def group_by(self, groups):
        group_list = str()
        for group in groups:
            group_list = str(group_list) + str(('GROUP BY' if len(group_list) == 0 else ',') + ' ' +
                                               str(group[0]) + '.' + # table
                                               str(group[1]))        # column
        return str(group_list)

    def inner_join(self, variables):
        string = str()
        for variable in variables:
            string = str(string) + str(str('INNER JOIN') + ' ' +
                                       str(variable[0]) + ' ' +                 # table
                                       str('ON') + ' ' +
                                       str(variable[0]) + '.' + 'rowid' + ' ' + # table.id
                                       '=' + ' ' +
                                       str(variable[1]) + ' ')                  # join_id
        return str(string)

    def select_versions(self):
        try:
            versions = set()
            con = sqlite3.connect(self.vira_db)
            cur = con.cursor()
            cur.execute('SELECT' + ' ' +
                        'issues.identifier' + ' ' + ',' + ' ' +
                        'projects.name' + ' ' + ',' + ' ' +
                        'versions.name' + ' ' + ',' + ' ' +
                        'versions.description' + ' '
                        'FROM' + ' ' +
                        'issues' + ' ' +
                        str(self.inner_join([
                            ['versions', 'issues.version_id'],
                            ['projects', 'issues.project_id'],
                            ['servers', 'projects.server_id']
                        ])) + ' ' +
                        'WHERE' + ' ' +
                        'servers.name' + ' ' + 'IS' + ' ' + '?' + ' ' +
                        'AND' + ' ' +
                        'projects.rowid' + ' ' + '=' + ' ' + 'versions.project_id' + ' ' +
                        str(self.group_by([
                            ['versions', 'name']
                        ])) + ' ' +
                        str(self.order_by([
                            ['projects', 'name', 'ASC'],
                            ['versions', 'name', 'DESC']
                        ])),
                        (str(self._get_serv()), ))
            projects = cur.fetchall()
            con.commit()
            con.close()
            for project in projects:
                version = str(project[2])
                description = str(project[3])
                #  percent = str(0)
                project = str(project[1])
                #  total = self.count_issue_version(str(project), version)
                fixed = self.count_issue_version_status(str(project), version, 'Done')
                percent = str(round(int(str(fixed[1])) / int(str(fixed[0])) * 100, 1)) if int(str(fixed[0])) != 0 else 1
                #  percent = str(self.version_percent(project[1], version))
                #  versions.add('│ ' + project + ' │ ' + version + ' │ ' + description + ' │ ' + percent + ' │')

        except Error as e:
            print(e)
            pass

        return versions
        #  print('│ None │')

    def insert_status(self, project, status, description):
        '''
        Update server details in the databas as required
        '''
        try:
            con = sqlite3.connect(self.vira_db)
            cur = con.cursor()
            # Confirm `project db row` exists
            try:
                project_id = self.select_project(str(project))[0]
            except:
                project_id = project
                pass

            try:
                status_id = str(self.select_status(str(project_id), str(status))[0])
            except:
                status_id = status
                pass

            try:
                cur.execute("UPDATE statuses SET description = '" + str(description) + "' WHERE rowid = " + str(status_id))
            except:
                cur.execute('INSERT OR REPLACE INTO statuses(project_id,name,description) VALUES (?,?,?)', (
                    str(project_id), str(status), str(description)))
                pass

            con.commit()
            con.close()

        except:
            pass

        return self.select_status(project, status)

    def select_status(self, project, status):
        '''
        Select current server `rowid`
        '''
        try:
            con = sqlite3.connect(self.vira_db)
            cur = con.cursor()
            cur.execute('SELECT rowid, * FROM statuses WHERE project_id=' + str(project) + ' AND name IS "' + str(status) + '"')
            row = cur.fetchone()
            con.commit()
            con.close()
        except Error as e:
            print(e)
            raise e
        return row

    def insert_type(self, project, name):
        '''
        Update server details in the databas as required
        '''
        try:
            con = sqlite3.connect(self.vira_db)
            cur = con.cursor()
            try:
                rowid = str(self.select_type(str(project), str(name))[0])
                cur.execute("UPDATE types SET name = '" + str(name) + "' WHERE rowid = " + str(rowid))
            except:
                project_id = self.select_project(str(project))[0]
                cur.execute('INSERT OR REPLACE INTO types (project_id,name) VALUES (?,?)', (
                    str(project_id), str(name)))
                pass
            con.commit()
            con.close()
        except:
            pass

        return self.select_type(project, name)

    def select_type(self, project, name):
        '''
        Select current server `rowid`
        '''
        try:
            con = sqlite3.connect(self.vira_db)
            cur = con.cursor()
            cur.execute('SELECT rowid, * FROM types WHERE project_id=' + str(self.select_project(project)[0]) + ' AND name IS "' + str(name) + '"')
            row = cur.fetchone()
            con.commit()
            con.close()
        except Error as e:
            print(e)
            raise e
        return row

    def insert_user(self, name, jira_id):
        '''
        Update server details in the databas as required
        '''
        con = sqlite3.connect(self.vira_db)
        cur = con.cursor()
        name = str(self.safe_string(name))
        jira_id = str(self.safe_string(jira_id))
        try:
            user = self.select_user(str(jira_id))
            rowid = str(user[0])
            cur.execute('UPDATE users SET name = "' + str(name) + '" WHERE rowid=' + rowid)
        except:
            try:
                server_id = self.db_serv[0]
                cur.execute('INSERT OR REPLACE INTO users(server_id,name,jira_id) VALUES (?,?,?)', (
                    str(server_id), str(name), str(jira_id)))
            except:
                #  TODO: VIRA-253 [210424] - This could be version or db usage overload
                # - We will miss a user if we get here
                raise OSError
            pass
        con.commit()
        con.close()
        return self.select_user(str(jira_id))

    def select_user(self, jira_id):
        '''
        Select current server `rowid`
        '''
        try:
            server_id = self.db_serv[0]

            con = sqlite3.connect(self.vira_db)
            cur = con.cursor()
            cur.execute('SELECT rowid, * FROM users WHERE server_id=' + str(server_id) + ' AND jira_id IS "' + str(jira_id) + '"')
            row = cur.fetchone()
            con.commit()
            con.close()
        except OSError as e:
            raise e
        return row

    def insert_issue(self, project, version, version_description, identifier, issueType, summary, status, created, updated):
        '''
        Create or update an issue
        :param con:
        :param issue:
        :return:
        '''

        # Project ID
        try:
            try:
                project_id = self.select_project(str(project))[0]
            except:
                try:
                    project_id = self.insert_project(str(project))[0]
                except OSError as e:
                    raise e
                pass

            self.insert_type(str(project), str(issueType))

            # Version ID check
            if str(version) != 'None':
                try:
                    version_id = self.select_version(str(project_id), str(version))[0]
                except:
                    version_id = self.insert_version(str(project_id), str(version), str(version_description))
                    print('VIRA: Version ' + str(version) + ', has been added to the ' + str(project) + ' project on ' + str(self._get_serv()) + '!')
                    pass
            else:
                version_id = 0

            # Status ID
            try:
                status_id = self.select_status(str(project_id), str(status))[0]
            except:
                try:
                    status_id = self.insert_status(str(project_id), str(status), str(str(status) + ' - Description'))[0]
                except:
                    status_id = 0
                    pass
                pass

            try:
                con = sqlite3.connect(self.vira_db)
                cur = con.cursor()
                try:
                    issue = self.select_issue(str(project_id), str(identifier))
                    summary = self.safe_string(summary)
                    cur.execute("UPDATE issues SET summary='" + str(summary) + "', status_id=" + str(status_id) + " WHERE updated < " + str(updated) + " AND rowid IS " + str(issue[0]))
                    #  if int(issue[7]) < int(updated):
                        #  print('Issue updated on ' + str(self._get_serv()) + ' - ' + str(project) + '-' + str(identifier) + ': ' + str(summary) + ' | ' + str(status) + ' ~ ' + str(updated))
                except:
                    try:
                        cur.execute('INSERT INTO issues(project_id,version_id,identifier,summary,status_id,created,updated) VALUES(?,?,?,?,?,?,?)',
                                    (str(project_id), str(version_id), str(identifier), str(summary), str(status_id), str(created), str(updated)))
                        #  print('New issue added to ' + str(self._get_serv()) + ' - ' + str(project) + '-' + str(identifier) + ': ' + str(summary) + ' | ' + str(status) + ' ~ ' + str(updated))
                    except:
                        self.create('issue')
                        raise Error
                    pass
                con.commit()
                con.close()
            except Error as e:
                print(e)
                raise e
        except:
            pass

        return self.select_issue(str(project_id), str(identifier))

        # Issue insert or update
        #  TODO: VIRA-253 [210326] - If there is a real update print a message
        #  - Move these to our `ViraStatusLine`
        #  - Should show only `identifier` and `field` that has been updated
        #  - This should be fine with a planed timer and sync with the jql search
        #  - Using it to confirm right now
                #  TODO: VIRA-253 [210319] - Create summary `db` with id links
                #  print('New issue added - ' + str(project) + '-' + str(identifier) + ': ' + str(summary) + ' | ' + str(status) + ' ~ ' + str(created))

    def select_issue(self, project, identifier):
        '''
        Select current server `rowid`
        '''
        try:
            con = sqlite3.connect(self.vira_db)
            cur = con.cursor()
            cur.execute('SELECT rowid, * FROM issues WHERE project_id=? AND identifier=?', (str(int(project)), str(int(identifier))))
            row = cur.fetchone()
            con.commit()
            con.close()
        except OSError as e:
            raise e
        return row

    def count_issue_version(self, project, version):
        '''
        Select current server `rowid`
        '''
        try:
            project_id = self.select_project(str(project))[0]
            version_id = self.select_version(str(project_id), str(version))[0]
            con = sqlite3.connect(self.vira_db)
            cur = con.cursor()
            cur.execute('SELECT COUNT(*) FROM issues WHERE project_id IS "' + str(project_id) + '" AND version_id IS "' + str(version_id) + '"')
            count = cur.fetchone()
            con.commit()
            con.close()
        except OSError as e:
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
            con = sqlite3.connect(self.vira_db)
            cur = con.cursor()
            cur.execute('SELECT COUNT(*) FROM issues WHERE project_id IS "' + str(project_id) + '" AND version_id IS "' + str(version_id) + '"')
            count.append(int(str(cur.fetchone()[0])))
            cur.execute('SELECT COUNT(*) FROM issues WHERE project_id IS "' + str(project_id) + '" AND version_id IS "' + str(version_id) + '" AND status_id IS "' + str(status_id) + '"')
            count.append(int(str(cur.fetchone()[0])))
            con.commit()
            con.close()
        except OSError as e:
            pass
        return count

    def latest_issue(self):
        '''
        Select current server `rowid`
        '''
        try:
            con = sqlite3.connect(self.vira_db)
            cur = con.cursor()
            cur.execute('SELECT' + ' ' + '*' + ',' + ' ' + 'servers.name' + ' ' + 'FROM' + ' ' + 'issues' + ' ' +
                        'INNER JOIN' + ' ' + 'projects' + ' ' + 'ON' + ' ' + 'projects.rowid' + ' ' + '=' + ' ' + 'issues.project_id' + ' ' +
                        'INNER JOIN' + ' ' + 'servers' + ' ' + 'ON' + ' ' + 'servers.rowid' + ' ' + '=' + ' ' + 'projects.server_id' + ' ' +
                        'WHERE' + ' ' + 'servers.name' + ' ' + 'IS' + ' ' + '"' + str(self._get_serv()) + '"' + ' ' +
                        'ORDER BY' + ' ' + 'issues.updated' + ' ' + 'DESC' + ' ' +
                        'LIMIT' + ' ' + '1')
            row = cur.fetchone()
            con.commit()
            con.close()
        except Error as e:
            print(e)
            pass
        return row
def __main__(self, file_db=vim.eval('g:vira_config_file_db')):
    pass
