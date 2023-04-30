" File: ftdetect/vira.vim {{{1
" Description: Vira file-type detections
" Authors:
"   n0v1c3 (Travis Gall) <https://github.com/n0v1c3>

augroup Vira
  autocmd!

  " Menu
  autocmd BufEnter vira_menu silent! setfiletype vira_menu
  autocmd BufEnter vira_menu call vira#_filter_load()
  autocmd Filetype vira_menu nnoremap <silent> <buffer> <cr> 0:call vira#_set()<cr>:q!<cr>:call vira#_refresh()<cr>
  autocmd Filetype vira_menu nnoremap <silent> <buffer> S :set hlsearch<cr>:call vira#_filter_all('select')<cr>
  autocmd Filetype vira_menu nnoremap <silent> <buffer> U :set hlsearch<cr>:call vira#_filter_all('unselect')<cr>
  autocmd Filetype vira_menu nnoremap <silent> <buffer> H :call vira#_toggle_hide()<cr>
  autocmd Filetype vira_menu nnoremap <silent> <buffer> D :call vira#_unset()<cr>:q!<cr>:call vira#_refresh()<cr>
  autocmd Filetype vira_menu nnoremap <silent> <buffer> j :set syntax=vira_menu<cr>gj
  autocmd Filetype vira_menu nnoremap <silent> <buffer> k :set syntax=vira_menu<cr>gk
  autocmd BufEnter vira_menu setlocal nowrap
  autocmd BufEnter vira_menu setlocal linebreak
  autocmd Filetype vira_menu setlocal norelativenumber
  autocmd Filetype vira_menu setlocal number
  autocmd Filetype vira_menu setlocal winfixheight

  " Report
  autocmd BufEnter vira_report silent! setfiletype vira_report
  autocmd BufEnter vira_report setlocal wrap
  autocmd BufEnter vira_report setlocal linebreak
  autocmd Filetype vira_report setlocal nonumber
  autocmd Filetype vira_report setlocal norelativenumber
  autocmd Filetype vira_report nnoremap <silent> <buffer> <cr> :call vira#_edit_report()<cr>
  autocmd Filetype vira_report noremap <silent> <buffer> j gj
  autocmd Filetype vira_report noremap <silent> <buffer> k gk

  " Common
  autocmd Filetype vira_menu,vira_report cnoremap <silent> <buffer> q!<cr> :q!<cr>:call vira#_resize()<cr>
  autocmd Filetype vira_menu,vira_report cnoremap <silent> <buffer> q<cr> :q!<cr>:call vira#_resize()<cr>
  autocmd Filetype vira_menu,vira_report nnoremap <silent> <buffer> q :q!<cr>:call vira#_resize()<cr>:call vira#_msg_error("E319", "q will be replaced by gq by version 0.5.0")<cr>
  autocmd Filetype vira_menu,vira_report cnoremap <silent> <buffer> gq!<cr> :q!<cr>:call vira#_resize()<cr>
  autocmd Filetype vira_menu,vira_report cnoremap <silent> <buffer> gq<cr> :q!<cr>:call vira#_resize()<cr>
  autocmd Filetype vira_menu,vira_report nnoremap <silent> <buffer> gq :q!<cr>:call vira#_resize()<cr>
  autocmd Filetype vira_menu,vira_report nnoremap <silent> <buffer> s :set hlsearch<cr>:call vira#_select()<cr>
  autocmd Filetype vira_menu,vira_report nnoremap <silent> <buffer> u :set hlsearch<cr>:call vira#_unselect()<cr>
  autocmd Filetype vira_menu,vira_report setlocal buftype=nowrite bufhidden=wipe noswapfile nowrap nobuflisted
  autocmd BufLeave vira_menu,vira_report call vira#_filter_unload()

  " Log the `cursor` position
  autocmd CursorMoved vira_menu,vira_report call vira#_virtualedit('all')
  autocmd CursorMoved vira_menu call vira#_cursor_pos('menu')
  autocmd CursorMoved vira_report call vira#_cursor_pos('report')
augroup END
