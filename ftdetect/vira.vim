" File: ftdetect/vira.vim {{{1
" Description: Vira filetype detection
" Authors:
"   n0v1c3 (Travis Gall) <https://github.com/n0v1c3>
" Version: 0.0.1

augroup Vira
  autocmd!
  autocmd BufNewFile,BufRead vira_report setf vira
  autocmd BufNewFile,BufRead vira_menu setf vira
  autocmd Filetype vira nnoremap <silent> <buffer> k gk
  autocmd Filetype vira nnoremap <silent> <buffer> q :q!<CR>
  autocmd Filetype vira vnoremap <silent> <buffer> j gj
  autocmd Filetype vira vnoremap <silent> <buffer> k gk
augroup END
augroup Vira2
  autocmd BufNewFile,BufRead vira_assign_issue setf vira2
  autocmd Filetype vira2 nnoremap <silent> <buffer> <cr> 0:call vira#_set_assign_issue()<cr>:q!<cr>:call vira#_refresh()<cr>
  autocmd Filetype vira2 nnoremap <silent> <buffer> k gk
  autocmd Filetype vira2 nnoremap <silent> <buffer> q :q!<CR>
  autocmd Filetype vira2 vnoremap <silent> <buffer> j gj
  autocmd Filetype vira2 vnoremap <silent> <buffer> k gk
augroup END
augroup Vira
  autocmd BufNewFile,BufRead vira_report setf vira
  autocmd BufNewFile,BufRead vira_menu setf vira
  autocmd Filetype vira nnoremap <silent> <buffer> <cr> 0:call vira#_set()<cr>:q!<cr>:call vira#_refresh()<cr>
augroup END
