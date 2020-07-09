" File: ftdetect/vira.vim {{{1
" Description: Vira filetypes detection
" Authors:
"   n0v1c3 (Travis Gall) <https://github.com/n0v1c3>

augroup Vira
  autocmd!
  autocmd BufNewFile,BufRead vira_report setf vira_report
  autocmd BufNewFile,BufRead vira_menu setf vira_menu

  " Report
  " autocmd BufEnter vira_report setlocal winfixwidth
  autocmd BufEnter vira_report setlocal nonumber
  autocmd BufEnter vira_report setlocal norelativenumber
  autocmd BufEnter vira_report nnoremap <silent> <buffer> <cr> :call vira#_edit_report()<cr>

  " Menu
  " autocmd BufLeave vira_menu call vira#_filter_reset()
  autocmd BufLeave vira_menu call vira#_filter_reset()
  autocmd BufEnter vira_menu call vira#_filter_reload()
  autocmd BufEnter vira_menu setlocal winfixheight
  autocmd BufEnter vira_menu setlocal norelativenumber
  autocmd BufEnter vira_menu setlocal number
  autocmd BufEnter vira_menu nnoremap <silent> <buffer> <cr> 0:call vira#_set()<cr>:q!<cr>:call vira#_refresh()<cr>
  autocmd BufEnter vira_menu nnoremap <silent> <buffer> S :call vira#_all('select')<cr>
  autocmd BufEnter vira_menu nnoremap <silent> <buffer> U :call vira#_all('unselect')<cr>
  autocmd BufEnter vira_menu nnoremap <silent> <buffer> s :call vira#_select()<cr>
  autocmd BufEnter vira_menu nnoremap <silent> <buffer> u :call vira#_unselect()<cr>

  " Common
  autocmd BufEnter vira_menu,vira_report cnoremap <silent> <buffer> q!<cr> :q!<cr>:call vira#_filter_reset()<cr>:call vira#_resize()<cr>
  autocmd BufEnter vira_menu,vira_report cnoremap <silent> <buffer> q<cr> :q!<cr>:call vira#_filter_reset()<cr>:call vira#_resize()<cr>
  autocmd BufEnter vira_menu,vira_report nnoremap <silent> <buffer> q :q!<cr>:call vira#_filter_reset()<cr>:call vira#_resize()<cr>
  autocmd BufEnter vira_menu,vira_report vnoremap <silent> <buffer> j gj
  autocmd BufEnter vira_menu,vira_report vnoremap <silent> <buffer> k gk
augroup END
