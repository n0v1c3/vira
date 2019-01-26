# vira

Vim JIRA interface plugin

## Installation

Add `n0v1c3/vira` to your favorite VIM package manager  
Add the following lines to your RC  
```
let g:vira_serv = "https://jira.website.com"
let g:vira_user = "username"
let g:vira_pass = "password"
```
## Usage

### Functions

#### ViraGetActiveIssue
```
ViraGetActiveIssue()
```
Get the currently selected active issue  
Examples:  
`statusline+=%{ViraGetActiveIssue()}` This can be used to display the active issue on your statusline.  

#### ViraSetActiveIssue
```
ViraSetActiveIssue()
```
Select active issue from a dropdown menu  
Examples:  
`nnoremap <leader>vi :call ViraSetActiveIssue()<cr>` Easy shortcut to select the active issue in normal mode.  

#### ViraInsertComment
```
ViraInsertComment()
```
Insert a comment into the code and JIRA for your active issue
Examples:  
`nnoremap <leader>vc :call ViraInsertComment()<cr>` Easy shortcut to select the active issue in normal mode.  
