# VIRA 0.4.14

**Vim JIRA Atlassian: Create, Update and Follow Along Jira Issues Actively
Without Leaving Vim!**

If you have made it this far there is a good chance that you already enjoy
staying inside of `vim` as much as you can. `vira` will help you stay on top of
your Jira development process without leaving your favorite environment.

![](https://raw.githubusercontent.com/n0v1c3/viravid/video/vira-demo.gif)

<ins>**_Table of Contents_**</ins>

- [Installation](#installation)
- [Configuration](#configuration)
  - [Jira server configuration (Required)](#jira_servers)
    - [Atlassian Cloud and API Token Notes](#token_notes)
  - [Quick start guide](#quick_start)
  - [Jira project configuration](#jira_projects)
    - [Filter config](#filter_config)
    - [New issue config](#issue_config)
    - [Issue sort order](#sort_config)
    - [Project templates](#project_templates)
    - [\_\_default\_\_ template](#default_template)
  - [Browser](#browser_config)
- [Menus and Reports](#menus)
  - [Commands](#commands)
  - [Reports](#report)
  - [.vimrc examples](#vimrc_examples)
- [Functions](#functions)
- [Configuration Variables](#config_vars)
- [Support](#support)
  - [Private and cloud Jira hosting](#private_cloud)
  - [Vim plugins](#vim_plugins)
    - [vim-fugitive](#fugitive)
    - [GV](#GV)
  - [name 'Vira' is not defined](#vira_not_defined)
- [Contributors](#contributors)

| <ins>**_VIRA 0.4.14 UPDATES:_**</ins>                                                 |
| ------------------------------------------------------------------------------------- |
| VIRA-213: `q` is going to be replaced by `gq` both will only work until `VIRA 0.5.0`. |
| VIRA-213: Added proper message inside `vim` and `nvim` for `q` removal.               |
| VIRA-283: Added `GV` syntax to `{code}` sections.                                     |
| VIRA-282: READ-ONLY for `report` and `menu` windows.                                  |
| VIRA-282: Track cursor position.                                                      |

| <ins>**_Recent Previous Releases:_**</ins>                                                  |
| ------------------------------------------------------------------------------------------- |
| 0.4.13 - remove manual login and README update (Travis Gall)                                |
| 0.4.12 - Don't append Null in non-empty server list (Krzysztof Konopko)                     |
| 0.4.11 - README remove old workarounds (Travis Gall)                                        |
| 0.4.10 - Handle missing assignee and guess current user correctly (Travis Gall)             |
| 0.4.9 - No Assignee "whatsoever", Missing **default**, and Default Sort (Krzysztof Konopko) |

<a name="installation"/>

## Installation

Example of vim-plug post-update hook to automatically install python
dependencies along with `vira`:

```vim
Plug 'n0v1c3/vira', { 'do': './install.sh' }
```

Alternatively, manually install the python3 dependencies:

```cmd
pip install --user jira
```

If you would like to be on board with the active development the `dev` branch
can be used:

```vim
Plug 'n0v1c3/vira', { 'do': './install.sh', 'branch': 'dev' }
```

<a name="configuration"/>

## Configuration

There are currently **two** separate files that are used in configuration. The
`~/.config/vira/vira_servers.json` file will be the **required** file for your
connections and `~/.config/vira/vira_projects.json` will map `projects` to
folders while linking them to `servers` inside `vira_servers.json`.

**NOTE:** Both of these files can be moved to other locations and set in your
`.vimrc`:

```vim
let g:vira_config_file_servers = $HOME . '/.config/vira/vira_servers.json'
let g:vira_config_file_projects = $HOME . '/.config/vira/vira_projects.json'
```

We also support trying the `yaml` configuration however, it will **require**
one more library for `python`. The default file-type is `json`, this is because
it comes "out of the box" inside of `python`. Run the following from the
`terminal` if you require `PyYAML` to enjoy `yaml`:

```cmd
pip install --user pyyaml
```

**NOTE:** When using `yaml` a link is **REQUIRED** in your `.vimrc` settings.

<a name="jira_servers"/>

### Jira server configuration (required):

For each Jira server, the following configuration variables are available, only
one of the options `password` or `password_cmd` will be set depending on a
**raw** password vs a password **command**:

- `username` - Jira server username.
- `password_cmd` - Run a CLI password manager such as `pass` or `lpass` to
  retrieve the Jira server password.
- `password` - Enter Jira server password in plain text. This is not
  recommended for security reasons, but we're not going to tell you how to live
  your life.
- `skip_cert_verify` - This option can be set in order to connect to a sever
  that is using self-signed TLS certificates.

The following is an example of a typical `vira_servers.json` configuration:

```json
{
  "https://n0v1c3.atlassian.net": {
    "username": "travis",
    "password_cmd": "lpass show --password account"
  },
  "https://jira.career.com": {
    "username": "mike",
    "password": "SuperSecretPassword",
    "skip_cert_verify": true
  }
}
```

Here is an example of the `vira_servers.yaml` configuration:

```yaml
https://n0v1c3.atlassian.net:
  username: user1
  password_cmd: lpass show --password account
  skip_cert_verify: true
https://jira.career.com:
  username: user2
  password: SuperSecretPassword
```

**IMPORTANT:** If only **ONE** the connection is automatic otherwise, a `menu`
will open to select a server. This can be avoided with the `__default__`
mapping, see [Jira Projects](#jira_projects).

**IMPORTANT:** If **NO** configuration is found you will be asked for a manual
URL, username, and password entry.

<a name="token_notes">

#### Atlassian Cloud and API Token Notes:

[Atlassian Cloud Jira Key](https://id.atlassian.com/manage-profile/security/api-tokens)
may be required if you are using the Atlassian Cloud service. Create an
`API token`. This `API token` is now the `password` set in your
`vira_servers.json` file.

<a name="quick_start"/>

### Quick start guide:

- Configure `~/.config/vira/vira_servers.json` as per [Jira servers configuration](#jira-servers).
- Run `:ViraServers` and select a server with `<cr>`.
- Run `:ViraIssues` and select an issue with `<cr>`.
- Run `:ViraReport` to view report.
- Press `<cr>` to edit any field.
- Rejoice because you have one less reason to leave `vim`!

Check out [Menus and Reports](#menus) after that for a list of commands and
tools that can be mapped to your `.vimrc` like the ones above.

<a name="jira_projects"/>

### Jira project configuration:

As mentioned in [Configuration](#configuration) a separate file
`vira_projects.json/yaml` can be created in the `vira` configuration directory.
`__default__` is also set up here to define the default server to use in the
other directories when there is more than one server mapped.

**NOTE:** When you're in a `git` repo, `vira` will auto-load your pre-defined
settings by matching the local repo name from file path.

**NOTE:** `vira` will only load the `vira_projects.json/yaml` configuration
automatically once per vim session. You can, however, manually switch servers
and filters as many times as you want after that.

For each Jira project, set:

- `server` - The Jira server to connect to (using authentication details from
  `vira_servers.json/yaml`).

The following is an example of a typical `vira_projects.json` configuration:

```json
{
  "__default__": {
    "server": "https://n0v1c3.atlassian.net"
  },
  "vira": {
    "server": "https://n0v1c3.atlassian.net"
  },
  "OtherProject": {
    "server": "https://jira.career.com"
  }
}
```

The following is an example of the same configuration in `yaml`:

```yaml
__default__:
  server: https://n0v1c3.atlassian.net
vira:
  server: https://n0v1c3.atlassian.net
OtherProject:
  server: https://jira.career.com
```

<a name="filter_config"/>

#### Filter configuration:

Default repo filters can be defined under a `filter` key as such:

```json
{
  "vira": {
    "server": "https://n0v1c3.atlassian.net",
    "filter": {
      "project": ["VIRA"],
      "assignee": ["Travis Gall"],
      "priority": ["High", "Highest"],
      "fixVersion": ["0.4.13"]
    }
  },
  "OtherProject": {
    "server": "https://jira.career.com",
    "filter": {
      "project": ["VQL"],
      "assignee": ["Travis Gall", "Mike Boiko"],
      "priority": ["low", "lowest"],
      "fixVersion": ["2.2.18"]
  }
}
```

```yaml
vira:
  server: https://n0v1c3.atlassian.net
  filter:
    project: [VIRA]
    assignee: [Mike Boiko]
    priority: [High, Highest]
    fixVersion: [1.1.1, 1.1.2]
OtherProject:
  server: https://jira.career.com
  filter:
    project: [MAIN]
    assignee: [Travis Gall]
    status: [In-Progress]
```

The acceptable values for the filter key are:

- `project` - Filter these projects. Can be a single item or list.
- `assignee` - Filter these assignees by display name. Can be a single item or list.
- `component` - Filter these components. Can be a single item or list.
- `epic` - Filter these epics. Can be a single item or list.
- `fixVersion` - Filter these versions. Can be a single item or list.
- `issuetype` - Filter the types of issues. Can be a single item or list.
- `priority` - Filter these priorities. Can be a single item or list.
- `reporter` - Filter these reporters. Can be a single item or list.
- `status` - Filter these statuses. Can be a single item or list.

**NOTE:** `currentUser` is also connected to the active account and can be used
for all user related tasks.

**IMPORTANT:** use the display name in `assignee` and `reporter`, as account
names will be unknown. You only know your own account number on Cloud services.

- example: "Travis Gall" vs
  `travis/848ab357sfd1c5e32effcd4657234e233/n0v1c3@gmail.com`

<a name="issue_config"/>

#### New issue configuration:

Similar to the `filter` key, you can define a `newissue` key to set repo-based.
Default configuration for the new-issue fields, for example in:

```json
{
  "vira": {
    "server": "https://n0v1c3.atlassian.net",
    "filter": {
      "project": ["VIRA"],
      "assignee": ["Travis Gall"],
      "priority": ["High", "Highest"],
      "fixVersion": ["0.4.13"]
    },
    "newissue": {
      "issuetype": "Task"
    }
  },
  "OtherProject": {
    "server": "https://jira.career.com",
    "filter": {
      "project": ["VIM", "TEST"],
      "assignee": ["Mike Boiko"],
      "priority": ["low", "lowest"],
    "newissue": {
      "assignee": "Travis Gall"
    }
  }
}
```

```yaml
vira:
  server: https://n0v1c3.atlassian.net
  filter:
    project: [VIRA]
    assignee: [Travis Gall]
    priority: [High, Hihest]
    fixVersion: [0.4.13]
  newissue:
    issuetype: [Task]
OtherProject:
  server: https://jira.career.com
  filter:
    assignee: [Travis Gall]
    status: [In-Progress]
  newissue:
    assignee: Travis Gall
```

The acceptable values for filter keys are:

- `assignee` - Define assignee.
- `component` - Define component. Note - these are project specific.
- `epic` - Define epic. Current project filters apply to list.
- `fixVersion` - Define fixVersion. Note - these are project specific.
- `issuetype` - Define issue type. The default is Bug.
- `priority` - Define priority.
- `status` - Define status. Vira will transition issue to this status.

<a name="sort_config"/>

#### Issue sort order:

Optionally, it is possible to define a custom sort order for the issues
displayed in `vira_menu`. This sort order is project based - meaning you
can define different sort orders for your projects.

Define the sort order using the `issuesort` key as follows:

```json
{
  "vira": {
    "server": "https:n0v1c3.atlasian.net",
    "issuesort": "status DESC"
  },
  "OtherProject": {
    "server": "https://jira.career.com",
    "filter": {
      "assignee": ["Travis Gall", "Mike Boiko"],
      "priority": ["Low", "Lowest"],
    "issuesort": {
      "status": "ASC",
      "updated": "DESC"
    }
  }
}
```

```yaml
vira:
  server: https://n0v1c3.atlassian.net
  issuesort: status
OtherProject:
  server: https://jira.career.com
  filter:
    assignee: Mike Boiko
    status: In-Progress
  issuesort:
    - status ASC
    - updated DESC
```

The value of `issuesort` can either be a string or a list. If no `issuesort`
key is provided, the default sort order used is `updated DESC`.

**NOTE:** that it is possible to define a custom status order in Jira-web in
Administration > Issues > Statuses. This can be used to achieve a similar
functionality to Kanban boards.

<a name="project_templates"/>

#### Project templates:

Templates can be defined in the same way that projects are defined. These
templates can be referenced for multiple projects, by using the template key.
Any name can be used for a template, but it is recommended to use the pythonic
syntax of `__name__` in order to make a distinction from a project. Refer to
the `yaml` example below, note that the priority in `repo2` will override the
`__maintemplate__` priority:

```json
{
  "__WORK__": {
    "server": "https:n0v1c3.atlasian.net",
    "filter": {
      "project": "VIRA",
      "assignee": ["Travis Gall"],
      "priority": ["High", "Highest"]
    }
  },
  "repo1": {
    "template": "__WORK__"
  },
  "repo2": {
    "template": "__WORK__",
    "filter": {
      "priority": "High"
    }
  }
}
```

```yaml
__WORK__:
  server: https://n0v1c3.atlassian.net
  filter:
    project: VIRA
    assignee: Travis Gall
    priority: [High, Highest]
repo1:
  template: __maintemplate__
repo2:
  template: __maintemplate__
  filter:
    priority: High
```

<a name="default_template"/>

#### `__default__` template:

If you would like to have a catch-all project configuration template, define a
`__default__` key in your `vira_projects.json/yaml` file. Refer to the `yaml`
example below:

```json
{
  "__default__": {
    "server": "https:n0v1c3.atlasian.net",
    "filter": {
      "assignee": ["Travis Gall"],
      "priority": ["High", "Highest"]
    },
    "newissue": {
      "issuetype": "Story"
    }
  }
}
```

```yaml
__default__:
  server: https://n0v1c3.atlassian.net
  filter:
    assignee: Mike Boiko
  newissue:
    issuetype: Task
```

<a name="browser_config"/>

### Browser:

By default, the `open` or `xdg-open` command will be used by `:ViraBrowse` to
open the current issue in the default browser. If either command is missing or
you wish to override the default browser, you may set the `g:vira_browser`
variable or provide the `BROWSER` environment variable.

Example setting **custom** default browser using `g:vira_browser`:

```vim
let g:vira_browser = 'chromium'
```

<a name="menus"/>

## Menus and Reports

A list of the important commands, functions and global variables for `menus`
and `reports` to be used to help configure Vira to work for you. There is also
a good example of `.vimrc` mapping and `report` layout.

<a name="commands"/>

### Commands

- `ViraBrowse` - View Jira issue in web-browser.
- `ViraComment` - Insert a comment for active issue.
- `ViraEditComment` - Update the comment relative to position in report.
- `ViraEditDescription` - Update the description of the current issue.
- `ViraEditSummary` - Update the summary of the current issue.
- `ViraFilterAssignees` - Add and remove assignees to filter.
- `ViraFilterComponents` - Add and remove components to filter.
- `ViraFilterEdit` - Display/Edit all active filter in a vim buffer.
- `ViraFilterEpics` - Add and remove epics to current filter.
- `ViraFilterPriorities` - Add and remove priorities to filter.
- `ViraFilterProjects` - Add and remove projects to filter.
- `ViraFilterReset` - Reset and remove filter to default.
- `ViraFilterStatuses` - Add and remove statuses to filter.
- `ViraFilterText` - Add and remove flexible issue text to filter.
- `ViraFilterTypes` - Add and remove issuetypes to filter.
- `ViraFilterVersions` - Add and remove versions to filter.
- `ViraIssue` - Create a new **issue**. The required fields are indicated by \*.
- `ViraIssues` - Get and Set the active **issue**.
- `ViraLoadProject` - Load project from `vira_projects.json/yaml`. The default is based on `cwd`. Optionally pass repo name in argument. Ex. `:ViraLoadProject My Repo`
- `ViraReport` - Get report for active issue.
- `ViraServers` - Get and Set active Jira server.
- `ViraSetAssignee` - Select user to assign the current issue.
- `ViraSetComponent` - Select component to append the current issue.
- `ViraSetEpic` - Select epic of the current issue.
- `ViraSetPriority` - Select priority of the current issue.
- `ViraSetStatus` - Select the status of the current issue.
- `ViraSetType` - Select the issuetype of the current issue.
- `ViraSetVersion` - Select the version to append the current issue.
- `ViraTodo` - Make a **TODO** note for current issue.
- `ViraTodos`- Get a list of the remaining TODOs.

**Menus (keys pre-mapped only to `menu` windows):**

- `D` - Unselect and Apply "Delete" all lines within menu.
- `H` - Toggle special hidden menu items.
- `s` - Select current line within menu.
- `S` - Select all lines within menu.
- `u` - Unselect current line within menu.
- `U` - Unselect all lines within menu.
- `q` - Quit the current menu with no apply.
- `<cr>` - Apply selections along with current line.

**NOTE:** It is possible to _select multiple_ items from all menus, if nothing
is selected prior to the item will be selected from the current column.

**Reports (keys pre-mapped only to `report` windows):**

- `<cr>` - Edit current `field` cursor is within.
- `s` - Select `issue` or `website` under cursor.

**NOTE:** `currentUser` is also connected to the active account and can be used
for all user related tasks. This can make it easier to create scripts with
different accounts.

<a name="report"/>

### Reports:

This is an example of a typical Jira issue report (except the report looks
colorized and fancy in vim):

```
+---------------------------------+
|            VIRA-134             |
+--------------+------------------+
|      Created | 2020-04-06 12:06 |
|      Updated | 2020-06-23 01:43 |
|         Type | Task             |
|       Status | In Progress      |
| Story Points | None             |
|     Priority | Highest          |
|    Epic Link | VIRA-32          |
|    Component | Software         |
|      Version | 1.0.0            |
|     Assignee | Mike Boiko       |
|     Reporter | Mike Boiko       |
+--------------+------------------+
+--------------+
|    Summary   |
+--------------+
Edit any Jira field

+--------------+
|  Description |
+--------------+
A user should be able to edit any field that
is shown on a vira issue report.

I would suggest to use a default key of <cr>
for editing a report field and allow the user
to customize this mapping.

The edit command would bring up the vira_prompt
buffer, in the same manner as creating new
issues/comments.

+--------------+
|   Comments   |
+--------------+
...
```

Most issue fields can be edited by pressing `<cr>`.

For the text entry fields (Summary, Description, Comments), if the text entry
is left blank, the write action will be aborted.

<a name="vimrc_examples"/>

### .vimrc examples:

```vim
" Basics
nnoremap <silent> <leader>vI :ViraIssue<cr>
nnoremap <silent> <leader>vS :ViraServers<cr>
nnoremap <silent> <leader>vT :ViraTodo<cr>
nnoremap <silent> <leader>vb :ViraBrowse<cr>
nnoremap <silent> <leader>vc :ViraComment<cr>
nnoremap <silent> <leader>vi :ViraIssues<cr>
nnoremap <silent> <leader>vr :ViraReport<cr>
nnoremap <silent> <leader>vt :ViraTodos<cr>

" Sets
nnoremap <silent> <leader>vsa :ViraSetAssignee<cr>
nnoremap <silent> <leader>vsp :ViraSetPriority<cr>
nnoremap <silent> <leader>vss :ViraSetStatus<cr>
nnoremap <silent> <leader>vse :ViraSetEpic<cr>
nnoremap <silent> <leader>vsv :ViraSetVersion<cr>

" Edits
nnoremap <silent> <leader>ved :ViraEditDescription<cr>
nnoremap <silent> <leader>ves :ViraEditSummary<cr>

" Filter search
nnoremap <silent> <leader>vfR :ViraFilterReset<cr>

nnoremap <silent> <leader>v/ :ViraFilterText<cr>

nnoremap <silent> <leader>vfP :ViraFilterPriorities<cr>
nnoremap <silent> <leader>vfa :ViraFilterAssignees<cr>
nnoremap <silent> <leader>vfe :ViraFilterEpics<cr>
nnoremap <silent> <leader>vfp :ViraFilterProjects<cr>
nnoremap <silent> <leader>vfr :ViraFilterReporter<cr>
nnoremap <silent> <leader>vfs :ViraFilterStatuses<cr>
nnoremap <silent> <leader>vft :ViraFilterTypes<cr>

" Projects/Boards
nnoremap <silent> <leader>vbm :ViraLoadProject __default__<cr>

" Functions
function! Enter_ViraActiveIssue()
    let g:vira_active_issue = input("Enter issue.key: ")
    ViraReport
endfunction
nnoremap <silent> <leader>vei :call Enter_ViraActiveIssue()<cr>

" Status
statusline+=%{ViraStatusline()}
```

<a name="functions"/>

## Functions

- `ViraGetActiveIssue()` - Get the currently selected active issue.
- `ViraStatusline()` - Quick statusline drop-in.

<a name="config_vars"/>

## Configuration Variables

- `g:vira_active_issue` - Set and get the active issue.
- `g:vira_async_timer` - Normal time between vim `async` updates. (10000ms)
- `g:vira_async_timer_init` - Faster initial time between `async` updates. (2000ms)
  - Lower the number to increase the rate of the initial versions listing.
  - WARNING: A lower number makes it "jumpy" but gets it over and onto `g:vira_async_timer` much faster.
- `g:vira_highlight` - Text used when there is no issue.
- `g:vira_issue_limit` - Set the maximum issue limit for query (default 50).
- `g:vira_menu_height` - Set the height of the menu (default 7).
  - Height - `g:vira_menu_height > 0` (may also equal 'J')
  - Tab - `g:vira_menu_height = 0` (may also equal 'T')
- `g:vira_null_issue` - Text used when there is no issue.
- `g:vira_report_width` - Set the width of the report (default 0).
  - Left - `g:vira_report_width > 0` (may also equal 'L')
  - Right - `g:vira_report_width < 0` (may also equal 'R')
  - Tab - `g:vira_report_width = 0` (may also equal 'T')
- `g:vira_version_hide` - Toggle the display of complete versions.

<a name="support"/>

## Support

<a name="private_cloud"/>

### Private and cloud Jira hosting:

We currently support Private Jira servers version 8 and up. We have not seen
issues with the lower versions we had access to but we no longer do have a
test platform.

The Cloud feature now available from Atlassian is currently also available.
The `API token` key referenced above is required to use as your `password`.

<a name="vim_plugins"/>

### Vim plugins:

Plugins may be used and supported. This list will build as required from other
requests. Support will be focused on providing functions that provide
information along with the related Jira commands for easy usage.

Below are a few common examples. Please recommend any other tools that could
use some good features to make your development easier.

<a name="fugitive"/>

#### vim-fugitive:

A simple example is below but recommended that it can be expanded on for your
personal needs.

```vim
function! s:Vira_GitActiveIssue()
    let g:vira_active_issue = execute("Git branch --show-current > echo")
    ViraReport
endfunction

function! s:Vira_GitCommit()
  " Commit current `git` status
  silent! execute 'Git commit'

  " Call prompt
  call s:Vira_GitPrompt()
endfunction

function! s:Vira_GitPrompt()
  if g:vira_active_issue != 'None'
    " Write current version
    redir @x>
      silent! echo g:vira_active_issue . ': '
    redir END
    put x

    " Delete blank lines
    goto 1
    join!
    join!
  endif
endfunction

nnoremap <silent> <leader>vgc :call Vira_GitCommit()<cr>
nnoremap <silent> <leader>vgi :call Vira_GitActiveIssue()<cr>
```

<a name="GV"/>

#### GV:

Most of us that have made it this far to use `vim` all day while using `git`
to merge our work together and `Jira` to track what we have done and needs
to be done coming up, [GV](https://github.com/junegunn/gv.vim) is very
helpful in nearly needing to leave our `vim` world. `vira` has added
in some `syntax` so that we will be able to see some useful `copy/paste`
in our `{code}` sections.

**NOTE:** Wrap with code and place ` {code:none}```GV``` ` as the header.

````
{code:none}
```GV```
*   2021-03-06 8a97263 VIRA 0.4.7 - temporary version filter bypass (Travis Gall)
|\
| * 2021-03-06 fd073bd VIRA-253: version update (Travis Gall)
| * 2021-03-06 0180e52 VIRA-253: temportaty `_async()` removed (Travis Gall)
|/
*   2021-03-05 e5ce063 VIRA 0.4.6 - `issuetype` menu typo (Travis Gall)
|\
| *   2021-03-05 daf502f VIRA-18: `issuetype` type patch (Travis Gall)
| |\
| | * 2021-03-05 43e33c0 VIRA-18: prepare version increase (Travis Gall)
| | * 2021-03-05 360cd97 VIRA-253: `issuetype` typo fix (Travis Gall)
| |/
| * 2021-03-04 85093b1 VIRA-245: Fixed summary/description line edit bug (Mike Boiko)
|/
*   2021-03-03 f9996e3 VIRA 0.4.5 - `report` reload bug patch (Travis Gall)
{code}
````

<a name="vira_not_defined"/>

#### name 'Vira' is not defined:

I have seen that users still make their way to issue
[#43](https://github.com/n0v1c3/vira/issues/43) once in a while. You may need
to update `python3_host_prog` that is stuck in version `0.4.1`.

**FROM:** [@uberbrodt](https://github.com/uberbrodt)

> Ok, so I finally got back around to looking at this. I tested with removing
> the `python3_host_prog` and it worked after I upgraded to `pynvim 0.4.2`
> (previous was at `0.4.1`).
>
> Setting the `python3_host_prog` again and then manually install the Jira
> package works as well. My suspicion is that the automatic install via
> vim-plug was not working with `virtualenv` for some reason, so might be
> something to note in the README. Thanks to everyone for debugging
> and offering advice!

<a name="contributors"/>

## Contributors

A big thank you to [@mikeboiko](https://github.com/mikeboiko) for his active
development on `vira`.

With growing support from:
[@chinwobble](https://github.com/chinwobble),
[@jamesl33](https://github.com/jamesl33),
[@kkonopko](https://github.com/kkonopko),
[@mattalexander-pantheon](https://github.com/kmattalexander-pantheon),
and [@maricn](https://github.com/maricn)

**All user feedback and contributions are welcome!**
