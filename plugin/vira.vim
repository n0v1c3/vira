" File: plugin/vira.vim {{{1
" Description: Internals and API functions for vira
" Authors:
"   n0v1c3 (Travis Gall) <https://github.com/n0v1c3>
" Version: 0.0.1

" Initialization {{{1
" Plugin Loaded {{{2
if exists('g:vira_loaded')
    finish
endif

" python check {{{2
if !has('python3')
  echo 'vim has to be compiled with +python3 to run vira'
  finish
endif

" Global Variables {{{1
" user-configuration files {{{2
let g:vira_config_file_projects = get(g:, 'vira_config_file_projects', $HOME.'/.config/vira/vira_projects.json')
let g:vira_config_file_servers = get(g:, 'vira_config_file_servers', $HOME.'/.config/vira/vira_servers.json')

" Null values {{{2
let g:vira_null_issue = get(g:, 'vira_null_issue', 'None')
let g:vira_null_project = get(g:, 'vira_null_project', 'None')

" Connections and filters {{{2
" Config
let g:vira_default_assignee = get(g:, 'vira_default_assigneee', '')
let g:vira_default_issuetype = get(g:, 'vira_default_issuetype', '')
let g:vira_default_priority = get(g:, 'vira_default_priority', '')
let g:vira_default_reporter = get(g:, 'vira_default_reporter', '')
let g:vira_default_status = get(g:, 'vira_default_status', ['To Do', 'In Progress'])

" Active
let g:vira_active_assignee = get(g:, 'vira_default_assigneee', '')
let g:vira_active_issuetype = get(g:, 'vira_default_issuetype', '')
let g:vira_active_priority = get(g:, 'vira_default_priority', '')
let g:vira_active_reporter = get(g:, 'vira_default_reporter', '')
let g:vira_active_status = get(g:, 'vira_default_status', ['To Do', 'In Progress'])

" Connections
let g:vira_active_issue = get(g:, 'vira_active_issue', g:vira_null_issue)
let g:vira_project = g:vira_null_project

" Commands {{{1
" Basics
command! -nargs=0 -bang ViraBrowse call vira#_browse()
command! -nargs=0 -bang ViraComment call vira#_comment()
command! -nargs=0 -bang ViraEpics call vira#_menu("epics")
command! -nargs=0 -bang ViraIssue call vira#_issue()
command! -nargs=0 -bang ViraIssues call vira#_menu("issues")
command! -nargs=0 -bang ViraQuit call vira#_quit()
command! -nargs=0 -bang ViraReport call vira#_menu('report')
command! -nargs=0 -bang ViraServers call vira#_menu('servers')
command! -nargs=0 -bang ViraTodo call vira#_todo()
command! -nargs=0 -bang ViraTodos call vira#_todos()

" Filters
command! -nargs=0 -bang ViraFilterReset call vira#_reset_filters()

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

" Load Vira Python Module {{{1
call vira#_init_python()
let g:vira_loaded = 1
