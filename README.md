# vira

Vim JIRA interface plugin.

Stay inside vim while following and updating Jira issues
along with creating new issues on the go.

## Installation

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

#### Atlassian Cloud Notes

[Atlassian Cloud Jira Key](https://id.atlassian.com/manage-profile/security/api-tokens)
may be required if you are using the Atlassian Cloud service.
Once an `API token` has been created that key can be used for `password`.

### Jira projects

The configuration for your jira project(s) needs to be done in a json or yaml file.
Similar to jira servers, default file file-type is json. The default file location is `~/.config/vira/vira_projects.json`

When you're in a git repo, vira will auto-load your pre-defined settings by matching the local repo name from file path.

For each jira project, set:

- `server` - The jira server to connect to (using authentication details from vira_servers.json/yaml)

The following is an example of a typical `vira_project.json` configuration:

```json
{
  "vira": {
    "server": "https://jira.site.com"
  },
  "OtherProject": {
    "server": "https://jira.othersite.com"
  }
}
```

The following is an example of the same configuration in yaml:

```yaml
vira:
  server: https://jira.site.com
OtherProject:
  server: https://jira.othersite.com
```

In order for vira to use the previous yaml example, set the following variable in your .vimrc:
`let g:vira_config_file_projects = $HOME.'/vira_projects.yaml'`

Note: Vira will only load the vira_projects.json/yaml configuration automatically once per vim session. You can, however, manually switch servers and filters as many times as you want after that. See Usage section.

#### Filters

Default repo filters can be defined under a `filter` key as such:

```yaml
vira:
  server: https://jira.site.com
  filter:
    project: VIRA
    assignee: mike
    priority: [High, Highest]
    fixVersion: [1.1.1, 1.1.2]
OtherProject:
  server: https://jira.othersite.com
  filter:
    project: MAIN
    assignee: travis
    status: In-Progress
```

The acceptable values for the filter key are:

- `project` - Filter these projects. Can be a single item or list.
- `assignee` - Filter these assignees. Can be a single item or list.
- `component` - Filter these components. Can be a single item or list.
- `fixVersion` - Filter these versions. Can be a single item or list.
- `issuetype` - Filter these issuetypes. Can be a single item or list.
- `priority` - Filter these priorities. Can be a single item or list.
- `reporter` - Filter these reporters. Can be a single item or list.
- `status` - Filter these statuses. Can be a single item or list.

#### New Issues

Similar to the `filter` key, you can define a `newissue` key to set repo-based
default configuration for the new-issue fields.

For example:

```yaml
vira:
  server: https://jira.site.com
  newissue:
    issuetype: Task
OtherProject:
  server: https://jira.othersite.com
  newissue:
    assignee: travis
  filter:
    assignee: travis
    status: In-Progress
```

The acceptable values for filter keys are:

- `assignee` - Define assignee.
- `component` - Define component. Note - these are project specific.
- `fixVersion` - Define fixVersion. Note - these are project specific.
- `issuetype` - Define issue type. The default is Bug.
- `priority` - Define priority.
- `status` - Define status. Vira will transition issue to this status.

#### Project Templates

Templates can be defined in the same way that projects are defined. These templates can be referenced for multiple projects, by using the template key.
Any name can be used for a template, but it is recommended to use the pythonic syntax of `__name__` in order to make a distinction from a project.
Refer to the yaml example below. Note that the priority in `repo2` will override the `__maintemplate__` priority.

```yaml
__maintemplate__:
  server: https://jira.site.com
  filter:
    project: VIRA
    assignee: travis
    priority: [High, Highest]
repo1:
  template: __maintemplate__
repo2:
  template: __maintemplate__
  filter:
    priority: High
```

#### Default Project Template

If you would like to have a catch-all project configuration template, define a `__default__` key in your vira_projects.json/yaml file.
Refer to the yaml example below.

```yaml
__default__:
  server: https://jira.site.com
  filter:
    assignee: mike
  newissue:
    issuetype: Task
```

### Browser

The default browser used for `:ViraBrowse` is the environment
variable `$BROWSER`. Override this by setting `g:vira_browser`.

```
let g:vira_browser = 'chromium'
```

## Usage

A list of the important commands, functions and global variables
to be used to help configure Vira to work for you.

### Keyboard

It is possible to _select multiple_ items from all menus,
if nothing is selected prior to the item will be selected
from the current column.

_NOTE:_ These keys are only mapped to the Vira windows.

- `s` - Select current line within menu
- `<cr>` - Apply selections or current line

### Commands

- `ViraBrowse` - View Jira issue in web-browser.
- `ViraComment` - Insert a comment for active issue.
- `ViraEpics` - Get and Set Project(s) epic issues.
- `ViraFilterAssignees` - Add assignees to filter.
- `ViraFilterComponents` - Add components to filter.
- `ViraFilterPriorities` - Add priorities to filter.
- `ViraFilterProjects` - Add projects to filter.
- `ViraFilterReset` - Reset filter to default.
- `ViraFilterStatuses` - Add statuses to filter.
- `ViraFilterText` - Add flexible issue text to filter.
- `ViraFilterTypes` - Add issuetypes to filter.
- `ViraFilterVersions` - Add versions to filter.
- `ViraIssue` - Create a new **issue**. The required fields are indicated by \*.
- `ViraIssues` - Get and Set the active **issue**.
- `ViraReport` - Get report for active issue.
- `ViraServers` - Get and Set active Jira server.
- `ViraSetAssignee` - Select user to assign the current issue.
- `ViraSetStatus` - Select the status of the current issue.
- `ViraTodo` - Make a **TODO** note for current issue.
- `ViraTodos`- Get a list of the remaining TODOs.

### Functions

- `ViraGetActiveIssue()` - Get the currently selected active issue.
- `ViraStatusline()` - Quick statusline drop-in.

### Variables

#### Nulls

- `g:vira_null_issue` - Text used when there is no issue.

### Examples:

```
" Basics
nnoremap <silent> <leader>vI :ViraIssue<cr>
nnoremap <silent> <leader>vS :ViraServers<cr>
nnoremap <silent> <leader>vT :ViraTodo<cr>
nnoremap <silent> <leader>vb :ViraBrowse<cr>
nnoremap <silent> <leader>vc :ViraComment<cr>
nnoremap <silent> <leader>ve :ViraEpics<cr>
nnoremap <silent> <leader>vi :ViraIssues<cr>
nnoremap <silent> <leader>vr :ViraReport<cr>
nnoremap <silent> <leader>vt :ViraTodos<cr>

" Sets
nnoremap <silent> <leader>vsa :ViraSetAssignee<cr>
nnoremap <silent> <leader>vss :ViraSetStatus<cr>

" Filter search
nnoremap <silent> <leader>v/ ViraFilterText<cr>

nnoremap <silent> <leader>vfP :ViraFilterPriorities<cr>
nnoremap <silent> <leader>vfa :ViraFilterAssignees<cr>
nnoremap <silent> <leader>vfp :ViraFilterProjects<cr>
nnoremap <silent> <leader>vfs :ViraFilterStatuses<cr>
nnoremap <silent> <leader>vfr :ViraFilterReporter<cr>
nnoremap <silent> <leader>vfR :ViraFilterReset<cr>
nnoremap <silent> <leader>vft :ViraFilterTypes<cr>

" Filter reset
nnoremap <silent> <leader>vfr :ViraFilterReset<cr>

" Status
statusline+=%{ViraStatusline()}
```

## Support
### Private and Cloud Jira Hosting

We currently support Private Jira servers version 8 and up. We
have not seen issues with the lower versions we had access to
but we no longer do have a test platform.

The Cloud feature now available from Atlassian is currently
also available. The `API token` key referenced above is required
to use as your `password`.

### Vim Plugins

Plugins may be used and supported. This list will build as required
from other requests. Support will be focused on providing functions
that provide information along with the related Jira commands for
easy usage.

Below are a few common examples. Please recommend any other tools
that could use some good features to make your development easier.

#### vim-fugitive

A simple example is below put recommended that it can be expanded on
for your personal needs.

```
function! s:VGprompt()
  return '"' . ViraStatusLine() . ': ' . input(ViraStatusLine() . ': ') . '"'
endfunction

execute 'Git checkout -b' . ViraStatusLine()
execute 'Git checkout ' . ViraStatusLine()
execute 'Git push -u origin ' . ViraStatusLine()
execute 'Git commit -m ' . s:VGprompt()
execute 'Gmerge --no-ff ' . ViraStatusLine() . ' -m ' . s:VGprompt()
```

#### airline

I am currently using the z section of airline until I figure
out the proper way to do it.

```
let g:airline_section_z = '%{ViraStatusLine()}'
```
