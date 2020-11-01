" File: ftdetect/vira.vim {{{1
" Description: Vira file-type detections
" Authors:
"   n0v1c3 (Travis Gall) <https://github.com/n0v1c3>

augroup Vira
  autocmd!
  autocmd BufNewFile,BufRead vira_menu setf vira_menu
  autocmd BufNewFile,BufRead vira_report setf vira_report

  " autocmd BufEnter vira_menu let t_back = &t_EI
  " autocmd BufEnter vira_menu let &t_EI = "\<esc>[4 q"
  " autocmd BufLeave vira_menu let &t_EI = t_back
  " autocmd BufEnter,BufLeave vira_menu execute('normal r')
  " autocmd Filetype vira_menu setlocal cursorline

  " Menu
  autocmd BufEnter vira_menu call vira#_filter_load()
  autocmd Filetype vira_menu nnoremap <silent> <buffer> <cr> 0:call vira#_set()<cr>:q!<cr>:call vira#_refresh()<cr>
  autocmd Filetype vira_menu nnoremap <silent> <buffer> S :set hlsearch<cr>:call vira#_filter_all('select')<cr>
  autocmd Filetype vira_menu nnoremap <silent> <buffer> U :set hlsearch<cr>:call vira#_filter_all('unselect')<cr>
  autocmd Filetype vira_menu nnoremap <silent> <buffer> d :set hlsearch<cr>
  autocmd Filetype vira_menu nnoremap <silent> <buffer> D :call vira#_unset()<cr>:q!<cr>:call vira#_refresh()<cr>
  autocmd Filetype vira_menu nnoremap <silent> <buffer> H :call vira#_toggle_hide()<cr>
  autocmd Filetype vira_menu nnoremap <silent> <buffer> u :set hlsearch<cr>:call vira#_unselect()<cr>
  autocmd Filetype vira_menu nnoremap <silent> <buffer> j :set syntax=vira_menu<cr>gj
  autocmd Filetype vira_menu nnoremap <silent> <buffer> k :set syntax=vira_menu<cr>gk
  autocmd Filetype vira_menu setlocal norelativenumber
  autocmd Filetype vira_menu setlocal number
  autocmd Filetype vira_menu setlocal winfixheight

  " Report
  " autocmd BufEnter vira_report setlocal winfixwidth
  autocmd Filetype vira_report setlocal nonumber
  " autocmd Filetype vira_report setlocal conceallevel=3
  autocmd Filetype vira_report setlocal norelativenumber
  autocmd Filetype vira_report nnoremap <silent> <buffer> <cr> :call vira#_edit_report()<cr>
  " autocmd Filetype vira_report nnoremap <silent> <buffer> j :set syntax=vira_report<cr>gj
  autocmd Filetype vira_report nnoremap <silent> <buffer> j gj
  " autocmd Filetype vira_report nnoremap <silent> <buffer> k :set syntax=vira_report<cr>gk
  autocmd Filetype vira_report nnoremap <silent> <buffer> k gk

  " Common
  autocmd Filetype vira_menu,vira_report cnoremap <silent> <buffer> q!<cr> :q!<cr>:call vira#_resize()<cr>
  autocmd Filetype vira_menu,vira_report cnoremap <silent> <buffer> q<cr> :q!<cr>:call vira#_resize()<cr>
  autocmd Filetype vira_menu,vira_report nnoremap <silent> <buffer> q :q!<cr>:call vira#_resize()<cr>
  autocmd Filetype vira_menu,vira_report nnoremap <silent> <buffer> s :set hlsearch<cr>:call vira#_select()<cr>
  autocmd Filetype vira_menu,vira_report setlocal buftype=nowrite bufhidden=wipe noswapfile nowrap nobuflisted
  autocmd BufLeave vira_menu,vira_report call vira#_filter_unload()
augroup END
