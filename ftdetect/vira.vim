" File: ftdetect/vira.vim {{{1
" Description: Vira filetype detection
" Authors:
"   n0v1c3 (Travis Gall) <https://github.com/n0v1c3>
" Version: 0.0.1

augroup Vira
  autocmd!
  autocmd BufNewFile,BufRead vira_report setf vira
  autocmd BufNewFile,BufRead vira_menu setf vira
  autocmd Filetype vira nnoremap <silent> <buffer> <cr> 0:call vira#_set()<cr>:q!<cr>:call vira#_refresh()<cr>
  autocmd Filetype vira nnoremap <silent> <buffer> k gk
  autocmd Filetype vira nnoremap <silent> <buffer> q :q!<cr>:call vira#_filter_reset()<cr>
  autocmd Filetype vira nnoremap <silent> <buffer> s :call vira#_select()<cr>
  autocmd Filetype vira vnoremap <silent> <buffer> j gj
  autocmd Filetype vira vnoremap <silent> <buffer> k gk
augroup END
