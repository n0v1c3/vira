" File: plugin/vira.vim {{{1
" Description: Internals and API functions for vira
" Authors:
"   n0v1c3 (Travis Gall) <https://github.com/n0v1c3>
"   mikeboiko (Mike Boiko) <https://github.com/mikeboiko>

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

" Config variables {{{2
let g:vira_null_issue = get(g:, 'vira_null_issue', 'None')
let g:vira_active_issue = get(g:, 'vira_active_issue', g:vira_null_issue)
let g:vira_load_project_enabled = 1
let g:vira_report_width = get(g:, 'vira_report_width', 0)
let g:vira_menu_height = get(g:, 'vira_menu_height', 7)
let g:vira_issue_limit = get(g:, 'vira_issue_limit', 50)
let g:vira_version_hide = get(g:, 'vira_version_hide', 1)

" Commands {{{1
" Basics
command! -nargs=0 -bang ViraBrowse call vira#_browse()
command! -nargs=0 -bang ViraComment call vira#_prompt_start('add_comment')
command! -nargs=0 -bang ViraEpics call vira#_menu("epics")
command! -nargs=0 -bang ViraIssue call vira#_prompt_start('issue')
command! -nargs=0 -bang ViraIssues call vira#_menu("issues")
command! -nargs=* -bang ViraLoadProject call vira#_load_project_config(<q-args>)
command! -nargs=0 -bang ViraQuit call vira#_quit()
command! -nargs=0 -bang ViraRefresh call vira#_refresh()
command! -nargs=0 -bang ViraReport call vira#_menu('report')
command! -nargs=0 -bang ViraServers call vira#_menu('servers')
command! -nargs=0 -bang ViraTodo call vira#_todo()
command! -nargs=0 -bang ViraTodos call vira#_todos()

" Sets
command! -nargs=0 -bang ViraSetAssignee call vira#_menu('assign_issue');
command! -nargs=0 -bang ViraSetComponent call vira#_menu('component');
command! -nargs=0 -bang ViraSetPriority call vira#_menu('priority');
command! -nargs=0 -bang ViraSetStatus call vira#_menu('set_status');
command! -nargs=0 -bang ViraSetVersion call vira#_menu('version');
command! -nargs=0 -bang ViraSetType call vira#_menu('issuetype');

" Edit
command! -nargs=0 -bang ViraEditDescription call vira#_prompt_start('description')
command! -nargs=0 -bang ViraEditSummary call vira#_prompt_start('summary')
command! -nargs=1 -bang ViraEditComment call vira#_prompt_start('edit_comment', '<args>')

" Filters
command! -nargs=0 -bang ViraFilterReset call vira#_reset_filters()
command! -nargs=0 -bang ViraFilterEdit call vira#_prompt_start('edit_filter')
command! -nargs=0 -bang ViraFilterAssignees call vira#_menu('assignees')
command! -nargs=0 -bang ViraFilterComponents call vira#_menu('components')
command! -nargs=0 -bang ViraFilterPriorities call vira#_menu('priorities')
command! -nargs=0 -bang ViraFilterProjects call vira#_menu('projects')
command! -nargs=0 -bang ViraFilterReporters call vira#_menu('reporters')
command! -nargs=0 -bang ViraFilterStatuses call vira#_menu('statuses')
command! -nargs=0 -bang ViraFilterText call vira#_menu('text')
command! -nargs=0 -bang ViraFilterTypes call vira#_menu('issuetypes')
command! -nargs=0 -bang ViraFilterVersions call vira#_menu('versions')

" Functions {{{1
function! ViraGetActiveIssue() "{{{2
  return vira#_get_active_issue()
endfunction

function! ViraStatusLine() "{{{2
  return vira#_get_statusline()
endfunction

" Load Vira Python Module {{{1
call vira#_init_python()
let g:vira_loaded = 1
