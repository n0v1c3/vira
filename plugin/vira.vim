" File: plugin/vira.vim {{{1
" Description: Internals and API functions for vira
" Authors:
"   n0v1c3 (Travis Gall) <https://github.com/n0v1c3>
" Version: 0.0.1

" Variables {{{1
" Globals {{{2
let g:vira_root_dir = fnamemodify(resolve(expand('<sfile>:p')), ':h') . '/..'
let g:virapy_path = g:vira_root_dir . '/py/vira.py'

" Null issue text {{{3
if !exists('g:vira_null_issue')
  let g:vira_null_issue = 'None'
endif

" Null project text {{{3
if !exists('g:vira_null_project')
  let g:vira_null_project = 'None'
endif

" Active issue text {{{3
if !exists('g:vira_active_issue')
  let g:vira_active_issue = g:vira_null_issue
endif

" Server selected {{{3
if !exists('g:vira_serv')
  let g:vira_serv = ''
endif

" virarc {{{3
if !exists('g:vira_virarc')
  let g:vira_virarc = '.virarc'
endif
" Will load all directories in the same order

" Home directory
if filereadable(expand('~/' . g:vira_virarc))
  exec 'source ~/' . g:vira_virarc
endif

" Git root directory
let s:vira_gitroot = system("git rev-parse --show-toplevel | tr -d '\\n'") . '/' . g:vira_virarc
if filereadable(expand(s:vira_gitroot))
  exec 'source ' . s:vira_gitroot
endif

" Commands {{{1
" VIRA-8 - Changed any functions that are not returning values for use into
" commands
command! -nargs=0 -bang ViraBrowse call vira#_browse()
command! -nargs=0 -bang ViraComment call vira#_comment()
command! -nargs=0 -bang ViraCommentInsert call vira#_insert_comment()
command! -nargs=0 -bang ViraGetReport call vira#_get_report()
command! -nargs=0 -bang ViraSetIssue call vira#_set_issue()
command! -nargs=0 -bang ViraSetProject call vira#_set_project()
command! -nargs=0 -bang ViraSetServer call vira#_set_server()

" Functions {{{1
function! ViraGetActiveIssue() "{{{2
  " Return the actuve issue key
  return vira#_get_active_issue()
endfunction

function! ViraStatusLine() "{{{2
  " Return formatted statusline string
  return vira#_get_statusline()
endfunction
