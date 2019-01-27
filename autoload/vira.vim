" File: autoload/vira.vim {{{1
" Description: Internals and API functions for vira
" Authors:
"   n0v1c3 (Travis Gall) <https://github.com/n0v1c3>
" Version: 0.0.1

" Variables {{{1
let s:vira_version = '0.0.1' "{{{2
if !exists('s:vira_statusline')
  let s:vira_statusline = g:vira_null_issue "{{{2
endif
if !exists('s:vira_is_init')
  " Clear the init flag
  let s:vira_is_init = 0  "{{{2
endif

if !exists('s:vira_issue_start_time')
  let s:vira_start_time = 0  "{{{2
endif

if !exists('s:vira_issue_end_time')
  let s:vira_end_time = 0  "{{{2
endif

" Functions {{{1
function! vira#_get_active_issue() "{{{2
  return g:vira_active_issue
endfunction

function! vira#_get_active_issue_desc() "{{{2
  " TODO-TJG [190126] - Python function required for active issue description
  return g:vira_active_issue
endfunction

function! vira#_get_active_issue_report() "{{{2
  " TODO-TJG [190126] - Python function required for active issue description

  echo "Test"
  echo vira#_get_active_issue()
endfunction

function! vira#_get_statusline() "{{{2
  return g:vira_active_issue
  python vim.exec("let s:vira_statusline = " . vira_statusline())
endfunction

function! vira#_get_version() "{{{2
  return s:vira_version
endfunction

function! vira#_init_python() "{{{2
  if (g:vira_pass=~"")
    let g:vira_pass = inputsecret('Enter password: ')
  endif

  " Load `py/vira.py`
  python import sys
  exe 'python sys.path = ["' . g:vira_root_dir . '"] + sys.path'
  exe 'pyfile ' . g:virapy_path

  " Set the init flag
  let s:vira_is_init = 1
endfunction
function! vira#_insert_comment() "{{{2
  " Confirm an issue has been selected
  if (vira#_get_active_issue()=~g:vira_null_issue)
    " User can select an issue now
    call vira#_dropdown()
  endif

  " Final chance to have a selected issue
  if !(vira#_get_active_issue()=~g:vira_null_issue)
    let comment = input(vira#_get_active_issue() . ": ")
    if !(comment=~"")
      execute "normal mmO" . vira#_get_active_issue() . " - " . comment . "\<esc>mn"
      call NERDComment(0, "Toggle")
      normal `m
      python vira_add_comment(vim.eval('vira#_get_active_issue()'), vim.eval('comment'))
    endif
  endif
endfunction

function! vira#_timestamp() "{{{2
  python vira_timestamp()
endfunction

function! vira#_dropdown() "{{{2
  if !s:vira_is_init
    call vira#_init_python()
  endif
  python vira_my_issues()
  popup &Vira
  call vira#_timestamp()
endfunction

