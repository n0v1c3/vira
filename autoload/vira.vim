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
let s:virapy_path = s:vira_root_dir . '/py/vira.py'

" Filters
let s:filter_project_key = "VIRA"

" Functions {{{1
function! vira#_get_active_issue() "{{{2
  return g:vira_active_issue
endfunction

function! vira#_get_active_issue_desc() "{{{2
  " TODO-TJG [190126] - Python function required for active issue description
  return g:vira_active_issue
endfunction

function! vira#_get_active_issue_report() "{{{2
  python vira_report(vim.eval("vira#_get_active_issue()"))
endfunction

function! vira#_get_statusline() "{{{2
  return g:vira_active_issue
  python vim.exec("let s:vira_statusline = " . vira_statusline())
endfunction

function! vira#_get_version() "{{{2
  return s:vira_version
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

  " Was a server chosen?
  if (exists('g:vira_serv') && g:vira_serv != '')
    " Load `py/vira.py` and connect to server
    silent! python import sys
    silent! exe 'python sys.path = ["' . s:vira_root_dir . '"] + sys.path'
    silent! exe 'pyfile ' . s:virapy_path
    silent! python vira_connect(vim.eval("g:vira_serv"), vim.eval("g:vira_user"), vim.eval("s:vira_pass_input"))

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

function! vira#_browse() "{{{2
  " Confirm an issue has been selected
  if (vira#_get_active_issue() == g:vira_null_issue)
    " User can select an issue now
    call vira#_set_issue()
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
      python vira_add_comment(vim.eval('vira#_get_active_issue()'), vim.eval('comment'))
    endif
  endif
endfunction

function! vira#_insert_comment() "{{{2
  " Confirm an issue has been selected
  if (vira#_get_active_issue() == g:vira_null_issue)
    " User can select an issue now
    call vira#_set_issue()
  endif

  " Final chance to have a selected issue
  if !(vira#_get_active_issue() == g:vira_null_issue)
    let comment = input(vira#_get_active_issue() . ": ")
    if !(comment == "")
      execute "normal mmO" . vira#_get_active_issue() . " - " . comment . "\<esc>mn"
      call NERDComment(0, "Toggle")
      normal `m
      python vira_add_comment(vim.eval('vira#_get_active_issue()'), vim.eval('comment'))
      echo comment
    endif
  endif
endfunction

function! vira#_check_init() "{{{2
  call vira#_update_virarc()
  if (s:vira_is_init != 1)
    call vira#_init_python()
  endif
  return s:vira_is_init == 1
endfunction

function! vira#_set_issue() "{{{2
  if (vira#_check_init())
    python vira_set_issue()
    silent! python vira_set_issue()
    popup &Vira
  endif
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

function! vira#_set_project() "{{{2
  if (vira#_check_init())
    python vira_get_projects()
    popup &Vira
  endif
endfunction

function! vira#_timestamp() "{{{2
  python vira_timestamp()
endfunction

function! vira#_get_report() "{{{2
  " let command = join(map(split(vira#_get_active_issue_repot()), 'expand(v:val)'))

  " Get the current winnr of the 'vira_report' buffer
  silent! let winnr = bufwinnr('^' . 'vira_report' . '$')

  " Toggle/create the report buffer
  if (winnr < 0)
    " Update user
    echo 'Issue: ' . vira#_get_active_issue() . ' report being updated.'

    " Open buffer into a window
    silent! execute 'botright vnew ' . fnameescape('vira_report')
    silent! setlocal buftype=nowrite bufhidden=wipe noswapfile nowrap nonumber nobuflisted
    silent! redraw
    silent! execute 'au BufUnload <buffer> execute bufwinnr(' . bufnr('#') . ') . ''wincmd w'''

    " Clean-up existing report buffer
    silent! normal ggVGd

    " Write report output into buffer
    silent! redir @x>|silent! call vira#_get_active_issue_report()|silent! redir END|silent! put x

    " Clean-up extra output
    silent! execute '%s/\^M//g'
    silent! execute 'normal gg2dd0'

    " TODO-TJG [190128] - Move this to a vimscript for the buffer {{{
    " Local key mappings
    silent! execute 'nnoremap <silent> <buffer> q :q<CR>'
    silent! execute 'nnoremap <silent> <buffer> j gj'
    silent! execute 'nnoremap <silent> <buffer> k gk'
    silent! execute 'vnoremap <silent> <buffer> j gj'
    silent! execute 'vnoremap <silent> <buffer> k gk'

    " Ensure wrap and linebreak are enabled
    silent! execute 'set wrap'
    silent! execute 'set linebreak'
    " }}}

    " Update user
    echo 'Issue: ' . vira#_get_active_issue() . ' report!'
  else
    " silent! execute winnr .'wincmd w'
    silent! execute winnr .'wincmd q'
  endif
endfunction
