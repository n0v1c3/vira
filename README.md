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
$HOME directory along with the current `git` directory `root`.

These files are the recomended places for storing your custom
configurations. The default setting that you require saved in your
$HOME directory and any project specific modifications.

Use a different filename:
```
let g:vira_virarc = '.virarc'
```
### Browser <!-- {{{3 -->

The default browser used for :ViraBrowse is the environment variable $BROWSER. Override this by setting g:vira_browser.
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
`nnoremap <silent> <leader>vc :ViraComment<cr>` -
Insert comment to active issue in normal mode.  
`nnoremap <silent> <leader>vC :ViraCommentInsert<cr>` -
Insert comment to active issue in normal mode.  
`nnoremap <silent> <leader>vi :ViraSetIssue<cr>` -
Select active issue in normal mode.  
`nnoremap <silent> <leader>vp :ViraSetProject<cr>` -
Select active project in normal mode.  
`nnoremap <silent> <leader>vr :ViraReport<cr>` -
Call report from normal mode  
`nnoremap <silent> <leader>vs :ViraSetServer<cr>` -
Change your active JIRA server  
`nnoremap <silent> <leader>vt :ViraGetTodo<cr>` -
Get the TODO notes  
`nnoremap <silent> <leader>vT :ViraTodo<cr>` -
Write a TODO note  
`statusline+=%{ViraStatusline()}` - Display the active issue
onto the status line.  

### Plugin Support: <!-- {{{3 -->
Plugins used and supported.

#### airline
*Full support planned*.

I am currently using the z section of airline until I figure
out the proper way to do it.
```
let g:airline_section_z = '%{ViraStatusLine()}'
