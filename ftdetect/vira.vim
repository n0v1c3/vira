" File: ftdetect/vira.vim {{{1
" Description: Vira filetypes detection
" Authors:
"   n0v1c3 (Travis Gall) <https://github.com/n0v1c3>

augroup Vira
  autocmd!
  autocmd BufNewFile,BufRead vira_report setf vira_report
  autocmd BufNewFile,BufRead vira_menu setf vira_menu

  " Report
  autocmd Filetype vira_report set noequalalways
  autocmd Filetype vira_report setlocal nonumber
  autocmd Filetype vira_report setlocal norelativenumber
  autocmd Filetype vira_report nnoremap <silent> <buffer> k gk
  autocmd Filetype vira_report nnoremap <silent> <buffer> q :q!<cr>:call vira#_filter_reset()<cr>
  autocmd Filetype vira_report nnoremap <silent> <buffer> s :call vira#_select()<cr>
  autocmd Filetype vira_report vnoremap <silent> <buffer> j gj
  autocmd Filetype vira_report vnoremap <silent> <buffer> k gk

  " Menu
  autocmd Filetype vira_menu setlocal norelativenumber
  autocmd Filetype vira_menu setlocal number
  autocmd Filetype vira_menu nnoremap <silent> <buffer> <cr> 0:call vira#_set()<cr>:q!<cr>:call vira#_refresh()<cr>
  autocmd Filetype vira_menu nnoremap <silent> <buffer> k gk
  autocmd Filetype vira_menu nnoremap <silent> <buffer> q :q!<cr>:call vira#_filter_reset()<cr>
  autocmd Filetype vira_menu nnoremap <silent> <buffer> s :call vira#_select()<cr>
  autocmd Filetype vira_menu vnoremap <silent> <buffer> j gj
  autocmd Filetype vira_menu vnoremap <silent> <buffer> k gk
augroup END
