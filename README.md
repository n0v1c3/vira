# vira

Vim JIRA interface plugin.

Stay inside vim while following and updating Jira issues
along with creating new issues on the go.

## Installation

Add to your vim plugin list in your .vimrc:

```
Plugin n0v1c3/vira
```

Example of vim-plug post-update hook to automatically install python dependencies along with vira:

```
Plug 'n0v1c3/vira', { 'do': './install.sh' }
```

Alternatively, manually install the python3 dependencies:

```
pip install --user jira
```

## Configuration

### Jira servers (required)

The configuration for your jira server(s) needs to be done in a json or yaml file.
The default file file-type is json, because it comes with the python standard library. The default file location is `~/.config/vira/vira_servers.json`

The following is an example of a typical `vira_servers.json` configuration:

```json
{
  "https://jira.site.com": {
    "username": "user1",
    "password_cmd": "lpass show --password account",
    "skip_cert_verify": true
  },
  "https://jira.othersite.com": {
    "username": "user2",
    "password": "SuperSecretPassword"
  }
}
```

For each jira server, the following configuration variables are available:

- `username` - Jira server username
- `password_cmd` - Run a CLI password manager such as `pass` or `lpass` to retrieve the jira server password.
- `password` - Enter jira server password in plain text. This is not recommended for security reasons, but we're not going to tell you how to live your life.
- `skip_cert_verify` - This option can be set in order to connect to a sever that is using self-signed TLS certificates.

If you can bear to install one additional python pip dependency, `PyYAML`, you can configure your settings in yaml:

```yaml
https://jira.site.com:
  username: user1
  password_cmd: lpass show --password account
  skip_cert_verify: true
https://jira.othersite.com:
  username: user2
  password: SuperSecretPassword
```

In order for vira to use the previous yaml example, set the following variable in your .vimrc:
`let g:vira_config_file_servers = $HOME.'/vira_servers.yaml'`

### Jira projects

The configuration for your jira project(s) needs to be done in a json or yaml file.
Similar to jira servers, default file file-type is json. The default file location is `~/.config/vira/vira_projects.json`

The following is an example of a typical `vira_project.json` configuration:

```json
{
  "vira": {
    "server": "https://jira.site.com",
    "project": "VIRA",
    "assignee": "Mike Boiko",
    "priority": ["High", "Highest"]
  },
  "OtherProject": {
    "server": "https://jira.othersite.com",
    "project": "MAIN",
    "assignee": "Travis Gall",
    "status": "In-Progress"
  }
}
```

When you're in a git repo, vira will auto-load your pre-defined settings by matching the local repo name from file path.
For each jira project, the following configuration variables are available:

- `server` - The jira server to connect to (using authentication details from vira_servers.json/yaml)
- `project` - Filter these projects. Can be a single item or list.
- `status` - Filter these statuses. Can be a single item or list.
- `assignee` - Filter these assignees. Can be a single item or list.
- `reporter` - Filter these reporters. Can be a single item or list.
- `priority` - Filter these priorities. Can be a single item or list.
- `issuetype` - Filter these issuetypes. Can be a single item or list.

The following is an example of the same configuration in yaml:

```yaml
vira:
  server: https://jira.site.com
  project: VIRA
  assignee: Mike Boiko
  priority: High, Highest
OtherProject:
  server: https://jira.othersite.com
  project: MAIN
  assignee: Travis Gall
  status: In-Progress
```

In order for vira to use the previous yaml example, set the following variable in your .vimrc:
`let g:vira_config_file_projects = $HOME.'/vira_projects.yaml'`

Note: Vira will only load the vira_projects.json/yaml configuration automatically once per vim session. You can, however, manually switch servers and filters as many times as you want after that.

#### Default Project Config

If you would like to have a catch-all project configuration template, define a `__default__` key in your vira_projects.json/yaml file. Refer to the yaml example below.

```yaml
__default__:
  server: https://jira.site.com
  project: VIRA
  assignee: Mike Boiko
  priority: High, Highest
```

### Browser

The default browser used for :ViraBrowse is the environment variable \$BROWSER. Override this by setting g:vira_browser.

```
let g:vira_browser = 'chromium'
```

## Usage

A list of the important commands, functions and global variables
to be used to help configure Vira to work for you.

### Commands

- `ViraBrowse` - View Jira issue in web-browser.
- `ViraComment` - Insert a comment for active issue.
- `ViraEpics` - Get and Set Project(s) epic issues.
- `ViraFilterAssignees` - Add assignees to filter.
- `ViraFilterPriorities` - Add priorities to filter.
- `ViraFilterProjects` - Add projects to filter.
- `ViraFilterReset` - Reset filter to default.
- `ViraFilterStatuses` - Add statuses to filter.
- `ViraFilterTypes` - Add issuetypes to filter.
- `ViraIssue` - Create a new **issue**.
- `ViraIssues` - Get and Set the active **issue**.
- `ViraReport` - Get report for active issue.
- `ViraServers` - Get and Set active Jira server.
- `ViraTodo` - Make a **TODO** note for current issue.
- `ViraTodos`- Get a list of the remaining TODOs.

### Functions

- `ViraGetActiveIssue()` - Get the currently selected active issue.
- `ViraStatusline()` - Quick statusline drop-in.

### Variables

#### Nulls

- `g:vira_null_issue` - Text used when there is no issue.
- `g:vira_null_project` - Text used when there is no project.

#### Filters

Filters are used to display the results of matching Jira issues.
The following variables are used for the **Default** vaules along with
the **Active** values for the filters. The default values are the
important ones to be set and insure that filters return to desired
state upon reset.

- `g:vira_default_assignee` - Default `assignee` filter
- `g:vira_default_issuetype` - Default `issuetype` filter
- `g:vira_default_priority` - Default `issuetype` filter
- `g:vira_default_report` - Default `report` filter
- `g:vira_default_status` - Default `status` filter

- `g:vira_active_assignee` - Active `assignee` filter
- `g:vira_active_issuetype` - Active `issuetype` filter
- `g:vira_active_priority` - Active `issuetype` filter
- `g:vira_active_report` - Active `report` filter
- `g:vira_active_status` - Active `status` filter

### Examples:

```
" Basics
nnoremap <silent> <leader>vI :ViraIssue<cr>
nnoremap <silent> <leader>vT :ViraTodo<cr>
nnoremap <silent> <leader>vb :ViraBrowse<cr>
nnoremap <silent> <leader>vc :ViraComment<cr>
nnoremap <silent> <leader>ve :ViraEpics<cr>
nnoremap <silent> <leader>vi :ViraIssues<cr>
nnoremap <silent> <leader>vr :ViraReport<cr>
nnoremap <silent> <leader>vs :ViraServers<cr>
nnoremap <silent> <leader>vt :ViraTodos<cr>

" Filter search
nnoremap <silent> <leader>vfP :ViraFilterPriorities<cr>
nnoremap <silent> <leader>vfa :ViraFilterAssignees<cr>
nnoremap <silent> <leader>vfp :ViraFilterProjects<cr>
nnoremap <silent> <leader>vfs :ViraFilterStatuses<cr>
nnoremap <silent> <leader>vfr :ViraFilterReporter<cr>
nnoremap <silent> <leader>vfR :ViraFilterReset<cr>
nnoremap <silent> <leader>vft :ViraFilterTypes<cr>

" Filter reset
nnoremap <silent> <leader>vfr :ViraFilterReset<cr>

" Filters (.virarc project)
let g:vira_default_assignee = ['']
let g:vira_default_issuetype = ['']
let g:vira_default_priority = ['']
let g:vira_default_reporter = ['']
let g:vira_default_status = ['To Do', 'In Progress']

" Status
statusline+=%{ViraStatusline()}
```

### Plugin Support:

Plugins used and supported. This list will build as required
from other requests.

#### airline

_Full support planned_.

I am currently using the z section of airline until I figure
out the proper way to do it.

```
let g:airline_section_z = '%{ViraStatusLine()}'
```
