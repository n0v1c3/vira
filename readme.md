# vira
Vim JIRA interface plugin

## Installation
Add `n0v1c3/vira` to your favorite VIM package manager  
Add the following lines to your `.vimrc`  
```
let g:vira_serv = "https://jira.website.com"
let g:vira_user = "username"
let g:vira_pass = "password"
```

### Important
Omit `let g:vira_pass` and you will be prompted for your password
only **once for each vim session** on the first usage. This will allow
you to keep your password out of your awesome publicly available
`dotfiles`.  

## Usage
### Functions
`ViraGetActiveIssue()` - Get the currently selected active issue.  
`ViraInsertComment()` - Insert comment into **JIRA** and **Code**
for your active issue.  
`ViraSetActiveIssue()` - Select active issue from a dropdown
menu.  
`ViraStatusline()` - Quick statusline drop-in

### Examples:
`statusline+=%{ViraStatusline()}` - Display the active issue
onto the status line.  
`nnoremap <silent> <leader>vi :call ViraSetActiveIssue()<cr>` -
select active issue in normal mode.  
`nnoremap <silent> <leader>vc :call ViraInsertComment()<cr>` -
Select active issue in normal mode.  

### Plugin Support:
#### airline
*Full support planned*  
I am currently using the z section of airline until I figure
out the proper way to do it.  
```
let g:airline_section_z = '%{ViraStatusLine()}'
```
