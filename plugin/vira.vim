" File: plugin/vira.vim {{{1
" Description: Internals and API functions for vira
" Authors:
"   n0v1c3 (Travis Gall) <https://github.com/n0v1c3>
" Version: 0.0.1

" Variables {{{1
" Globals {{{2
let g:vira_root_dir = fnamemodify(resolve(expand('<sfile>:p')), ':h') . '/..'
let g:virapy_path = g:vira_root_dir . '/py/vira.py'

" Null issue text {{{3
if !exists('g:vira_null_issue')
  let g:vira_null_issue = 'No Issue Selected'
endif

" Active issue text {{{3
if !exists('g:vira_active_issue')
  let g:vira_active_issue = g:vira_null_issue
endif

" Functions {{{1
function! ViraSetActiveIssue() "{{{2
 call vira#_dropdown()
endfunction

function! ViraGetActiveIssue() "{{{2
  return vira#_get_active_issue()
endfunction

function! ViraGetActiveIssueReport() "{{{2
  redir @">|silent call vira#_get_active_issue_report()|redir END|vnew|put
endfunction

function! ViraInsertComment() "{{{2
  call vira#_insert_comment()
endfunction
function! ViraStatusLine() "{{{2
  return vira#_get_statusline()
endfunction

" Thanks: epsilonhalbe
" https://stackoverflow.com/questions/10493452/vim-open-a-temporary-buffer-displaying-executables-output
function! ViraGetActiveIssueReport() " {{{
    let command = join(map(split(vira#_get_active_issue_repot()), 'expand(v:val)'))
    let winnr = bufwinnr('^' . command . '$')
    silent! execute  winnr < 0 ? 'botright vnew ' . fnameescape(command) : winnr . 'wincmd w'
    setlocal buftype=nowrite bufhidden=wipe nobuflisted noswapfile nowrap nonumber
    echo 'Execute ' . command . '...'
    silent! execute 'silent %!'. command
    silent! redraw
    silent! execute 'au BufUnload <buffer> execute bufwinnr(' . bufnr('#') . ') . ''wincmd w'''
    silent! execute 'nnoremap <silent> <buffer> <LocalLeader>r :call <SID>ExecuteInShell(''' . command . ''')<CR>:AnsiEsc<CR>'
    silent! execute 'nnoremap <silent> <buffer> q :q<CR>'
    silent! execute 'AnsiEsc'
    echo 'Shell command ' . command . ' executed.'
endfunction " }}}
command! -complete=shellcmd -nargs=+ Shell call s:ExecuteInShell(<q-args>)
nnoremap <leader>! :Shell
