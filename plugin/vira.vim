" File: plugin/vira.vim {{{1
" Description: Internals and API functions for vira
" Authors:
"   n0v1c3 (Travis Gall) <https://github.com/n0v1c3>
" Version: 0.0.1

let g:vira_root_dir = fnamemodify(resolve(expand('<sfile>:p')), ':h') . '/..'
let g:virapy_path = g:vira_root_dir . '/py/vira.py'
let g:vira_active_issue = ''

nnoremap <leader>vc :call vira#_dropdown()<CR>

" Clear the init flag
let g:vira_is_init = 0
function! vira#_set_active_issue(issue) "{{{1
  let g:vira_active_issue = a:issue
  execute "normal! mmO" . g:vira_active_issue . "\<esc>`m"
endfunction

function! vira#_dropdown() "{{{1
  if !g:vira_is_init
    call vira#_init_python()
  endif
  python vira_my_issues()
  popup &Vira
  execute "normal mmO" . g:vira_active_issue . "\<esc>mn"
  call NERDComment(0, 'Toggle')
  normal `m
endfunction

function! vira#_init_python() "{{{1
  " let vira_pass = inputsecret('Enter password: ')

  " Load `py/vira.py`
  python import sys
  exe 'python sys.path = ["' . g:vira_root_dir . '"] + sys.path'
  exe 'pyfile ' . g:virapy_path

  " Set the init flag
  let g:vira_is_init = 1
endfunction
