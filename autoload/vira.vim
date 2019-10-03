" File: autoload/vira.vim {{{1
" Description: Internals and API functions for vira
" Authors:
"   n0v1c3 (Travis Gall) <https://github.com/n0v1c3>
" Version: 0.0.1

" Variables {{{1
let s:vira_version = '0.0.1'
let s:vira_is_init = 0

let s:vira_statusline = g:vira_null_issue
let s:vira_start_time = 0
let s:vira_end_time = 0

let s:vira_root_dir = fnamemodify(resolve(expand('<sfile>:p')), ':h') . '/..'
let s:virapy_path = s:vira_root_dir . '/python'

let s:vira_todo_header = 'TODO'

" Filters
let s:filter_project_key = 'VIRA'

" Functions {{{1
function! vira#_browse() "{{{2
  " Confirm an issue has been selected
  if (vira#_get_active_issue() == g:vira_null_issue)
    " User can select an issue now
    silent! call vira#_set_issue()
  endif

  " Create url path from server and issue key
  let l:url = g:vira_serv . '/browse/' . vira#_get_active_issue()

  " Set browser - either user defined or $BROWSER
  if exists('g:vira_browser')
    let l:browser = g:vira_browser
  else
    let l:browser = $BROWSER
  endif

  " User needs to define a browser
  if l:browser == ''
    echoerr 'Please set $BROWSER environment variable or g:vira_browser vim variable before running :ViraBrowse'
    return
  endif

  " Open current issue in browser
  execute 'term ++close ' . l:browser . ' "' . l:url . '"'

endfunction

function! vira#_check_init() "{{{2
  if (s:vira_is_init != 1)
    call vira#_update_virarc()
    call vira#_init_python()
  endif
  return s:vira_is_init == 1
endfunction

function! vira#_comment() "{{{2
  " Confirm an issue has been selected
  if (vira#_get_active_issue() == g:vira_null_issue)
    " User can select an issue now
    call vira#_set_issue()
  endif

  " Final chance to have a selected issue
  if !(vira#_get_active_issue() == g:vira_null_issue)
    let comment = input(vira#_get_active_issue() . ": ")
    if !(comment == "")
      python3 Vira.api.add_comment(vim.eval('vira#_get_active_issue()'), vim.eval('comment'))
    endif
  endif
endfunction

function! vira#_get_active_issue() "{{{2
  return g:vira_active_issue
endfunction

function! vira#_get_active_issue_desc() "{{{2
  " TODO-TJG [190126] - Python function required for active issue description
  return g:vira_active_issue
endfunction

function! vira#_get_statusline() "{{{2
  return g:vira_active_issue
  python3 vim.exec("let s:vira_statusline = " . vira_statusline())
endfunction

function! vira#_get_version() "{{{2
  return s:vira_version
endfunction

function! vira#_init_python() "{{{2
  " Confirm a server has been selected, this can be done outside of this init
  silent! let vira_serv_config = 1
  if (!exists('g:vira_serv') || g:vira_serv == '')
    silent! let vira_serv_config = 0
    call vira#_set_server()
  endif
  
  " User/password lookup
  let i = 0
  for serv in g:vira_srvs
    if (serv == g:vira_serv)
      let g:vira_user = g:vira_usrs[i]
      if (!exists('g:vira_pass'))
        let s:vira_pass_input = inputsecret('Enter password: ')
      else
        let s:vira_pass_input = system(g:vira_pass[i])[:-2]
      endif
    endif
    let i = i + 1
  endfor

  " Specify whether the server's TLS certificate needs to be verified
  let g:vira_skip_cert_verify = get(g:, 'vira_skip_cert_verify', '0')

  " Was a server chosen?
  if (exists('g:vira_serv') && g:vira_serv != '')
    " Load `py/vira.py` and connect to server
    silent! python3 import sys
    silent! exe 'python3 sys.path.append(f"' . s:vira_root_dir . '")'
    silent! python3 import Vira
    silent! python3 Vira.api.connect(vim.eval("g:vira_serv"), vim.eval("g:vira_user"), vim.eval("s:vira_pass_input"), vim.eval("g:vira_skip_cert_verify"))

    " Check if Vira connected to the server
    if (s:vira_is_init != 1)
      " Inform user with possible errors and reset unconfigured information
      echo "\nNot logged in! Check configuration and CAPTCHA"
      if (vira_serv_config == 0)
        let g:vira_serv = ""
      endif
    endif
    
    " Clear password
    let s:vira_pass_input = ""
  endif
endfunction

function! vira#_issue() "{{{2
  " Add issue only if a project has been selected
  if !(g:vira_project == g:vira_null_project || g:vira_project == "")
    let summary = input(g:vira_project . " - Issue Summary: ")
    if !(summary == "")
      let description = input(g:vira_project . " - Issue Description: ")
      python3 Vira.api.add_issue(vim.eval('g:vira_project'), vim.eval('summary'), vim.eval('description'), "Bug")
    else
      echo "\nSummary should not be blank"
    endif
  endif
endfunction

function! vira#_menu(type) "{{{2
  if (vira#_check_init())
    " let command = join(map(split(vira#_get_active_issue_repot()), 'expand(v:val)'))

    " Get the current winnr of the 'vira_report' buffer
    if a:type == 'report'
      silent! let winnr = bufwinnr('^' . 'vira_report' . '$')
    else
      silent! let winnr = bufwinnr('^' . 'vira_menu' . '$')
    endif

    " Toggle/create the report buffer
    if (winnr < 0)
      " Open buffer into a window
      if a:type == 'report'
        silent! execute 'botright vnew ' . fnameescape('vira_report')
      else
        silent! execute 'botright new ' . fnameescape('vira_menu')
        silent! execute 'resize 7'
      endif
      silent! setlocal buftype=nowrite bufhidden=wipe noswapfile nowrap nonumber nobuflisted
      silent! redraw
      silent! execute 'au BufUnload <buffer> execute bufwinnr(' . bufnr('#') . ') . ''wincmd w'''

      " Clean-up existing report buffer
      silent! normal ggVGd

      " Write report output into buffer
      silent! redir @x>
      silent! execute 'python3 Vira.api.get_' . a:type . '()'
      silent! redir END
      silent! put x

      " TODO: VIRA-46 [190927] - Make the fold and line numbers only affect the window type {{{
      " Remove folding and line numbers from the report
      silent! let &foldcolumn=0
      silent! set relativenumber!
      silent! set nonumber
      " }}}

      " Clean-up extra output
      silent! execute '%s/\^M//g'
      silent! normal GV3kzogg2dd0

      " TODO: VIRA-80 [190928] - Move mappings to ftplugin {{{
      " Key mapping
      silent! execute 'nnoremap <silent> <buffer> <cr> :call vira#_set_' . a:type . '()<cr>:q!<cr>'
      silent! execute 'nnoremap <silent> <buffer> k gk'
      silent! execute 'nnoremap <silent> <buffer> q :q!<CR>'
      silent! execute 'vnoremap <silent> <buffer> j gj'
      silent! execute 'vnoremap <silent> <buffer> k gk'
      " }}}

      " Ensure wrap and linebreak are enabled
      silent! execute 'set wrap'
      silent! execute 'set linebreak'
    else
      silent! execute winnr .'wincmd q'
      call vira#_menu(a:type)
    endif
  endif
endfunction

function! vira#_set_server() "{{{2
  " Confirm server list is set by user
  if exists('g:vira_srvs')
    " Build and display the menu
    amenu&Vira.&<tab>:e <cr>
    aunmenu &Vira
    " VIRA-14 - Update the server name and the user name commands
    let i = 0
    for serv in g:vira_srvs
      execute('amenu&Vira.&' . escape(serv, '\\/.*$^~[]') . '<tab>:silent! e :let g:vira_serv = ' . '"' . serv . '"' . '<cr>:let g:vira_user = "' . g:vira_usrs[i] . '"<cr>')
      let i = i + 1
    endfor
    silent! popup &Vira
  else
    echo 'g:vira_srvs has not been set'
  endif
endfunction

function! vira#_set_issues() "{{{2
  execute 'normal <c-v>vf hy'
  let g:vira_active_issue = expand('<cWORD>')
endfunction

function! vira#_set_projects() "{{{2
  execute 'normal <c-v>wey'
  let g:vira_project = expand('<cword>')
endfunction

function! vira#_set_servers() "{{{2
  execute 'normal 0<c-v>$y'
  let g:vira_serv = expand('<cWORD>')
  call vira#_init_python()
endfunction

function! vira#_todo() "{{{2
  " Build default or issue header
  let comment_header = s:vira_todo_header
  if !(vira#_get_active_issue() == g:vira_null_issue)
    let comment_header .=  ": " . vira#_get_active_issue()
  endif
  let comment_header .= " [" . strftime('%y%m%d') . "] - "

  " Comment entry from user
  let comment = input(comment_header)

  " Post existing comments in the file and on the issue if selected
  if !(comment == "")
    " Jira comment
    let file_path = "{code}\n" . @% . "\n{code}"
    if !(vira#_get_active_issue() == g:vira_null_issue)
      python3 Vira.api.add_comment(vim.eval('vira#_get_active_issue()'), vim.eval('file_path . "\n*" . s:vira_todo_header . "* " . comment'))
    endif

    " Vim comment
    execute "normal mmO" . comment_header . comment . "\<esc>mn"
    call NERDComment(0, "Toggle")
    normal `m
  endif
endfunction

function! vira#_todos() "{{{2
  " Binary files that can be ignored
  set wildignore+=*.jpg,*.docx,*.xlsm,*.mp4,*.vmdk
  " Seacrch the CWD to find all of your current TODOs
  vimgrep /TODO.*\[\d\{6}]/ **/* **/.* | cw 5
  " Un-ignore the binary files
  set wildignore-=*.jpg,*.docx,*.xlsm,*.mp4,*.vmdk
endfunction

function! vira#_timestamp() "{{{2
  python3 Vira.timestamp()
endfunction

function! vira#_update_virarc() "{{{2
  let s:vira_is_init = 0
  if !exists('g:vira_virarc')
    let g:vira_virarc = '.virarc'
  endif

  " virarc home directory
  if filereadable(expand('~/' . g:vira_virarc))
    exec 'source ~/' . g:vira_virarc
  endif

  " Save current directory and switch to file direcotry
  let s:current_dir = execute("pwd")
  cd %:p:h

  " Find git root directory
  let s:vira_gitroot = system("git rev-parse --show-toplevel | tr -d '\\n'") . '/' . g:vira_virarc

  " Return to current directory
  cd `=s:current_dir`

  " Source when found
  if filereadable(expand(s:vira_gitroot))
    exec 'source ' . s:vira_gitroot
  endif
endfunction
