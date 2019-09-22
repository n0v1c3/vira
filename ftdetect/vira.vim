" File: ftdetect/vira.vim {{{1
" Description: Vira filetype detection
" Authors:
"   n0v1c3 (Travis Gall) <https://github.com/n0v1c3>
" Version: 0.0.1

augroup Vira
  autocmd!
  autocmd BufNewFile,BufRead vira_report setf vira
augroup END
