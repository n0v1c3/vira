# vira
Vim JIRA interface plugin

## Installation
Add `n0v1c3/vira` to your favorite VIM package manager and finaly
install JIRA into Python.  
```
sudo python2 -m pip install jira
sudo python3 -m pip install jira
```  

## Configuration
Add the following lines to your `.vimrc`  
```
let g:vira_serv = "https://jira.website.com"
let g:vira_user = "username"
```  
You will be propted for your password only **once for each vim session**
on the first usage.  

### External Password Management
The `system` command can be used to get your password from external
sources. Below is an example using the `lpass` function, **please
note the `[:-2]` being used to remove the endline character.**  
```
let g:vira_user = system('lpass show --username account')[:-2]
let g:vira_pass = system('lpass show --password account')[:-2]
```  
### Multiple JIRA Servers
By omitting the above `g:vira_serv` and instead using the below configuration
you will be able to quickly hop between diferent JIRA servers.  
```
let g:vira_srvs = ['https://jira.website.com', 'https://jira.othersite.com']
```  
## Usage
### Functions
`ViraGetActiveIssue()` - Get the currently selected active issue.  
`ViraInsertComment()` - Insert comment into **JIRA** and **Code**
for your active issue.  
`ViraSetActiveIssue()` - Select active issue from a dropdown
menu.  
`ViraStatusline()` - Quick statusline drop-in.  
`ViraReport()` - Get a report for the active issue  
`ViraServer()` - Change your active JIRA server

### Examples:
`statusline+=%{ViraStatusline()}` - Display the active issue
onto the status line.  
`nnoremap <silent> <leader>vi :call ViraSetActiveIssue()<cr>` -
Select active issue in normal mode.  
`nnoremap <silent> <leader>vc :call ViraInsertComment()<cr>` -
Insert comment to active issue in normal mode.  
`nnoremap <silent> <leader>vr :call ViraInsertComment()<cr>` -
Call report from normal mode  
`nnoremap <silent> <leader>vs :call ViraServer()<cr>` -
Change your active JIRA server  

### Plugin Support:
#### airline
*Full support planned*  
I am currently using the z section of airline until I figure
out the proper way to do it.  
```
let g:airline_section_z = '%{ViraStatusLine()}'
```
