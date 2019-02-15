# vira <!-- {{{1 -->
Vim JIRA interface plugin

## Installation <!-- {{{2 -->
Add `n0v1c3/vira` to your favorite VIM package manager and finaly
install JIRA into Python.
```
sudo python2 -m pip install jira
sudo python3 -m pip install jira
```

## Configuration <!-- {{{2 -->
### Required <!-- {{{3 -->
Add the following lines to your `.vimrc`
```
let g:vira_srvs = ['https://jira.website.com', 'https://jira.othersite.com']
let g:vira_usrs = ['username_website', 'username_othersite']
```
These lists should be of equal length with at least **one** entry each
and represent the address of the JIRA site along with the user
names being used to log in.

You will be propted for your password only **once for each vim session**
on the first usage.

### External Password Management <!-- {{{3 -->
The `system` command can be used to get your password from external
sources. Below is an example using the `lpass` function, **please
note the `[:-2]` being used to remove an endline character.**
```
let g:vira_user = system('lpass show --username account')[:-2]
let g:vira_pass = system('lpass show --password account')[:-2]
```
#### Development Note
I have not yet completed how to make this work with multiple accounts
properly but I will.

### Browser <!-- {{{3 -->

The default browser used for :ViraBrowse if firefox. Set the following variable to change it.
```
let g:vira_browser = 'chromium'
```

## Usage <!-- {{{2 -->
A list of the important commands, functions and global variables
to be used to help configure Vira to work for you.

### Commands <!-- {{{3 -->
`ViraBrowse` - View JIRA issue in web-browser.
`ViraComment` - Insert a comment into JIRA for your active issue.
`ViraInsertComment` - Insert comment into **JIRA** and **Code** for your active issue.
`ViraSetIssue` - Select active **issue** from a dropdown menu.
`ViraSetProject` - Select active **project** from a dropdown menu.
`ViraGetReport` - Get a report fr the active issue
`ViraSetServer` - Change your active JIRA server

### Functions <!-- {{{3 -->
`ViraGetActiveIssue()` - Get the currently selected active issue.
`ViraStatusline()` - Quick statusline drop-in.

### Variables <!-- {{{3 -->
`g:vira_null_issue` - Text used when there is no issue.
`g:vira_null_project` - Text used when there is no project.

### Examples: <!-- {{{3 -->
`nnoremap <silent> <leader>vi :ViraSetIssue<cr>` -
Select active issue in normal mode.
`nnoremap <silent> <leader>vi :ViraSetProject<cr>` -
Select active project in normal mode.
`nnoremap <silent> <leader>vs :ViraSetServer<cr>` -
Change your active JIRA server
`nnoremap <silent> <leader>vc :ViraComment<cr>` -
Insert comment to active issue in normal mode.
`nnoremap <silent> <leader>vC :ViraInsertComment<cr>` -
Insert comment to active issue in normal mode.
`nnoremap <silent> <leader>vr :ViraReport<cr>` -
Call report from normal mode
`statusline+=%{ViraStatusline()}` - Display the active issue
onto the status line.

### Plugin Support: <!-- {{{3 -->
Plugins used and supported.

#### airline
*Full support planned*
I am currently using the z section of airline until I figure
out the proper way to do it.
```
let g:airline_section_z = '%{ViraStatusLine()}'
```
