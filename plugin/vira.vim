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


" Global Variables {{{1
" vira_virarc {{{2
let g:vira_virarc = get(g:, 'vira_virarc', '.virarc')

" vira_skip_cert_verify {{{2
let g:vira_skip_cert_verify = get(g:, 'vira_skip_cert_verify', '0')

" vira_null_issue {{{2
let g:vira_null_issue = get(g:, 'vira_null_issue', 'None')

" vira_null_project {{{2
let g:vira_null_project = get(g:, 'vira_null_project', 'None')
let g:vira_project = g:vira_null_project

" vira_active_issue {{{2
let g:vira_active_issue = get(g:, 'vira_active_issue', g:vira_null_issue)

" vira_serv {{{2
let g:vira_serv = get(g:, 'vira_serv', '')

" vira_serv {{{2
let g:vira_srvs = get(g:, 'vira_srvs', [])

" vira_filter_assignees {{{2
let g:vira_filter_assignees = get(g:, 'vira_filter_assigneees', '')

" vira_filter_issuetype {{{2
let g:vira_filter_issuetype = get(g:, 'vira_filter_issuetype', '')

" vira_filter_priorities {{{2
let g:vira_filter_priorities = get(g:, 'vira_filter_priorities', '')

" vira_filter_reporters {{{2
let g:vira_filter_reporters = get(g:, 'vira_filter_reporters', '')

" vira_filter_status {{{2
let g:vira_filter_status = get(g:, 'vira_filter_status', ['"To Do"', '"In Progress"'])

" call vira#_init()

" Commands {{{1
" VIRA-8 - Changed any functions that are not returning values for use into commands
" Basics
command! -nargs=0 -bang ViraBrowse call vira#_browse()
command! -nargs=0 -bang ViraComment call vira#_comment()
command! -nargs=0 -bang ViraEpics call vira#_menu("epics")
command! -nargs=0 -bang ViraIssue call vira#_issue()
command! -nargs=0 -bang ViraIssues call vira#_menu("issues")
command! -nargs=0 -bang ViraQuit call vira#_quit()
command! -nargs=0 -bang ViraReport call vira#_report()
command! -nargs=0 -bang ViraServers call vira#_servers()
command! -nargs=0 -bang ViraTodo call vira#_todo()
command! -nargs=0 -bang ViraTodos call vira#_todos()

" Filters
command! -nargs=0 -bang ViraFilterAssignees call vira#_menu("assignees")
command! -nargs=0 -bang ViraFilterPriorities call vira#_menu("priorities")
command! -nargs=0 -bang ViraFilterProjects call vira#_menu("projects")
command! -nargs=0 -bang ViraFilterReporters call vira#_menu("reporters")
command! -nargs=0 -bang ViraFilterStatuses call vira#_menu("statuses")
command! -nargs=0 -bang ViraFilterTypes call vira#_menu("issuetypes")

" Functions {{{1
function! ViraGetActiveIssue() "{{{2
  " Return the actuve issue key
  return vira#_get_active_issue()
endfunction

function! ViraStatusLine() "{{{2
  " Return formatted statusline string
  return vira#_get_statusline()
endfunction
