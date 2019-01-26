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

#### ViraGetActiveIssue
`ViraGetActiveIssue()` - Get the currently selected active issue.  
**Examples:**  
`statusline+=%{ViraGetActiveIssue()}` - Display the active issue
onto the status line.  

#### ViraSetActiveIssue
`ViraSetActiveIssue()` - Select active issue from a dropdown
menu.  
**Examples:**  
`nnoremap <silent> <leader>vi :call ViraSetActiveIssue()<cr>` -
select active issue in normal mode.  

#### ViraInsertComment
`ViraInsertComment()` - Insert comment into **JIRA** and **Code**
for your active issue.  
**Examples:**  
`nnoremap <silent> <leader>vc :call ViraInsertComment()<cr>` -
Select active issue in normal mode.  
