# vira

Vim JIRA interface plugin

## Installation

Add `n0v1c3/vira` to your favorite VIM package manager and finaly
install JIRA into Python.

```
sudo python3 -m pip install jira
```

## Configuration

### Required

Add the following lines to your `.vimrc`

```
let g:vira_srvs = ['https://jira.website.com', 'https://jira.othersite.com']
let g:vira_usrs = ['username_website', 'username_othersite']
let g:vira_pass = ['pass jira/website/n0v1c3', 'lpass show --password account']
```

These lists should be of equal length with at least **one** entry each
and represent the address of the JIRA site along with the user
names being used to log in.

Passwords are calls to external commands such as `pass` and `lpass`. A simple
`echo` chould be used but this would not be a safe way to save the passwords.

You will be propted for your password only **once for each vim session**
on the first usage.

### .virarc

The `.virarc` file(s) can be used to load the required settings for all
projects. Currently there will be a `.virarc` file searched for in user's
\$HOME directory along with the current `git` directory `root`.

These files are the recomended places for storing your custom
configurations. The default setting that you require saved in your
\$HOME directory and any project specific modifications.

Use a different filename:

```
let g:vira_virarc = '.virarc'
```

### Browser

The default browser used for :ViraBrowse is the environment variable \$BROWSER. Override this by setting g:vira_browser.

```
let g:vira_browser = 'chromium'
```

### TLS Certificate Verification

The following option can be set in order to connect to a sever that is using self-signed TLS certificates.

```
let g:vira_skip_cert_verify = 1
```

## Usage

A list of the important commands, functions and global variables
to be used to help configure Vira to work for you.

### Commands

- `ViraBrowse` - View JIRA issue in web-browser.
- `ViraComment` - Insert a comment into JIRA for your active issue.
- `ViraGetReport` - Get a report fr the active issue.
- `ViraGetTodo` - Get a list of the remaining TODOs.
- `ViraGetIssues` - Select active **issue** from a menu.
- `ViraGetProjects` - Select active **project** from a menu.
- `ViraSetServer` - Change your active JIRA server.
- `ViraTodo` - Make a TODO note for current issue.

### Functions

- `ViraGetActiveIssue()` - Get the currently selected active issue.
- `ViraStatusline()` - Quick statusline drop-in.

### Variables

- `g:vira_null_issue` - Text used when there is no issue.
- `g:vira_null_project` - Text used when there is no project.

### Examples:

```
nnoremap <silent> <leader>vc :ViraComment<cr>
nnoremap <silent> <leader>vi :ViraGetIssues<cr>
nnoremap <silent> <leader>vp :ViraGetProjects<cr>
nnoremap <silent> <leader>vr :ViraReport<cr>
nnoremap <silent> <leader>vs :ViraSetServer<cr>
nnoremap <silent> <leader>vt :ViraGetTodo<cr>
nnoremap <silent> <leader>vT :ViraTodo<cr>
statusline+=%{ViraStatusline()}
```

### Plugin Support:

Plugins used and supported.

#### airline

_Full support planned_.

I am currently using the z section of airline until I figure
out the proper way to do it.

```
let g:airline_section_z = '%{ViraStatusLine()}'
```
