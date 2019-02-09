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
  let g:vira_null_issue = 'No Issue Selected'
endif

" Active issue text {{{3
if !exists('g:vira_active_issue')
  let g:vira_active_issue = g:vira_null_issue
endif

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
command! -nargs=0 -bang ViraDropdown call vira#_dropdown()
command! -nargs=0 -bang ViraComment call vira#_comment()
command! -nargs=0 -bang ViraCommentInsert call vira#_insert_comment()
command! -nargs=0 -bang ViraReport call vira#_report()
command! -nargs=0 -bang ViraServer call vira#_set_server()

" Functions {{{1
function! ViraDropdown() "{{{2
 call vira#_dropdown()
endfunction

" Return the actuve issue key
function! ViraGetActiveIssue() "{{{2
  return vira#_get_active_issue()
endfunction

function! ViraStatusLine() "{{{2
  return vira#_get_statusline()
endfunction
