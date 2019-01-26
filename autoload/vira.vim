" File: autoload/vira.vim {{{1
" Description: Internals and API functions for vira
" Authors:
"   n0v1c3 (Travis Gall) <https://github.com/n0v1c3>
" Version: 0.0.1
let s:vira_version = '0.0.1'

" Initialization flag
if !exists('s:vira_is_init')
  let s:vira_is_init = 0
endif

" Functions {{{1
function! vira#_get_version() "{{{2
  return s:vira_version
endfunction

" Clear the init flag
function! vira#_set_active_issue(issue) "{{{2
  let g:vira_active_issue = a:issue
  execute "normal! mmO" . g:vira_active_issue . "\<esc>`m"
endfunction

function! vira#_dropdown() "{{{2
  if !s:vira_is_init
    call vira#_init_python()
  endif
  python vira_my_issues()
  popup &Vira
  execute "normal mmO" . g:vira_active_issue . "\<esc>mn"
  call NERDComment(0, 'Toggle')
  normal `m
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
