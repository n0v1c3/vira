" File: plugin/vira.vim {{{1
" Description: Internals and API functions for vira
" Authors:
"   n0v1c3 (Travis Gall) <https://github.com/n0v1c3>
" Version: 0.0.1

nnoremap <leader>vc :call vira#_dropdown()<CR>

function! g:QuickComment() "{{{1
  amenu &Vira.&Source<Tab>:e  :source ./plugin/vira.vim<CR>
  amenu &Vira.&Tasks<Tab>:e  :call SetTODO("TJG")<CR>
  popup &Vira
endfunction

function! g:TestPy() range "{{{1

  let startline = line("'<")
  let endline = line("'>")
  echo "vim-start:".startline . " vim-endline:".endline

python << EOF
import vim

s = "I was set in python"
vim.command("let sInVim = '%s'"% s)
start = vim.eval("startline")
end = vim.eval("endline")
print "start, end in python:%s,%s"% (start, end)
EOF

  echo sInVim
endfunction

function! vira#_dropdown() "{{{1
  " py vim.command('let issues=['+vira_my_issues()+']')
  python vira_my_issues()
  " exec 'amenu $Vira.' . issues
  " amenu &Vira.&Source<Tab>:e  :source ./plugin/vira.vim<CR>
  " amenu &Vira.&Tasks<Tab>:e  :call SetTODO("TJG")<CR>
  popup &Vira
  " popup &Vira
endfunction

function! vira#_init_python() "{{{1
  " Path to the file location
  let virapy_path = s:path . '/py/vira.py'
  " let virapy_path = '/home/travis/Documents/development/n0v1c3/vira' . '/py/vira.py'

  let vira_serv = 'https://jira.boiko.online'
  let vira_user = input('Enter username: ')
  let vira_pass = inputsecret('Enter password: ')

  " Load `py/vira.py`
  python import sys
  exe 'python sys.path = ["' . s:path . '"] + sys.path'
  " exe 'python sys.path = ["' . '/home/travis/Documents/development/n0v1c3/vira' . '"] + sys.path'
  exe 'pyfile ' . virapy_path
endfunction

call vira#_init_python()
