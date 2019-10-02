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

" TODO-MB [190924] - print test
silent! python3 import sys
" let g:testvar = eval("python3 print(sys.path)")
let vira_root_dir = '/home/mike/.vim/plugged/vira/python'
exe 'python3 sys.path.append(f"'.vira_root_dir.'")'
python3 import Vira
python3 print(dir(Vira))
python3 Vira.api.vira_test()
echo g:testvar

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
command! -nargs=0 -bang ViraEpics call vira#_menu("epics")
command! -nargs=0 -bang ViraIssue call vira#_issue()
command! -nargs=0 -bang ViraTodo call vira#_todo()

" get_set mixed commands
command! -nargs=0 -bang ViraAssignees call vira#_menu("assignees")
command! -nargs=0 -bang ViraIssueTypes call vira#_menu("issuetypes")
command! -nargs=0 -bang ViraIssues call vira#_menu("issues")
command! -nargs=0 -bang ViraPriorities call vira#_menu("priorities")
command! -nargs=0 -bang ViraProjects call vira#_menu("projects")
command! -nargs=0 -bang ViraReport call vira#_menu("report")
command! -nargs=0 -bang ViraReporters call vira#_menu("reporters")
command! -nargs=0 -bang ViraServers call vira#_menu("servers")
command! -nargs=0 -bang ViraStatuses call vira#_menu("statuses")
command! -nargs=0 -bang ViraUsers call vira#_menu("users")
command! -nargs=0 -bang ViraTodos call vira#_todos()

" Functions {{{1
function! ViraGetActiveIssue() "{{{2
  " Return the actuve issue key
  return vira#_get_active_issue()
endfunction

function! ViraStatusLine() "{{{2
  " Return formatted statusline string
  return vira#_get_statusline()
endfunction
