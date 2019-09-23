" File: plugin/vira.vim {{{1
" Description: Internals and API functions for vira
" Authors:
"   n0v1c3 (Travis Gall) <https://github.com/n0v1c3>
" Version: 0.0.1

" Initialization {{{1

if !has('python3')
  echo 'vim has to be compiled with +python3 to run vira'
  finish
endif

" Variables {{{1
" Globals {{{2
" virarc {{{3
" Null issue text {{{3
if !exists('g:vira_null_issue')
  let g:vira_null_issue = 'None'
endif

" Null and default project text {{{3
if !exists('g:vira_null_project')
  let g:vira_null_project = 'None'
endif
let g:vira_project = g:vira_null_project

" Active issue text {{{3
if !exists('g:vira_active_issue')
  let g:vira_active_issue = g:vira_null_issue
endif

" Server selected {{{3
if !exists('g:vira_serv')
  let g:vira_serv = ''
endif

" Commands {{{1
" VIRA-8 - Changed any functions that are not returning values for use into
" commands
command! -nargs=0 -bang ViraBrowse call vira#_browse()
command! -nargs=0 -bang ViraComment call vira#_comment()
command! -nargs=0 -bang ViraAddIssue call vira#_add_issue()
command! -nargs=0 -bang ViraGetReport call vira#_get_report()
command! -nargs=0 -bang ViraGetTodos call vira#_get_todo()
command! -nargs=0 -bang ViraSetIssue call vira#_set_issue()
command! -nargs=0 -bang ViraSetProject call vira#_set_project()
command! -nargs=0 -bang ViraSetServer call vira#_set_server()
command! -nargs=0 -bang ViraTodo call vira#_todo()

" Functions {{{1
function! ViraGetActiveIssue() "{{{2
  " Return the actuve issue key
  return vira#_get_active_issue()
endfunction

function! ViraStatusLine() "{{{2
  " Return formatted statusline string
  return vira#_get_statusline()
endfunction
