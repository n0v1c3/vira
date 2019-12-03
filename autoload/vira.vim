" File: autoload/vira.vim {{{1
" Description: Internals and API functions for vira
" Authors:
"   n0v1c3 (Travis Gall) <https://github.com/n0v1c3>
" Version: 0.0.1

" Variables {{{1
let s:vira_version = '0.0.1'
let s:vira_is_init = 0
let s:vira_is_connect = 0

let s:vira_statusline = g:vira_null_issue
let s:vira_start_time = 0
let s:vira_end_time = 0

let s:vira_root_dir = fnamemodify(resolve(expand('<sfile>:p')), ':h') . '/..'

let s:vira_todo_header = 'TODO'

let s:vira_filters=['assignee', 'issuetype', 'priority', 'reporter', 'status']

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

function! vira#_connect() "{{{2
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
    " Connect to server
    silent! python3 Vira.api.connect(vim.eval("g:vira_serv"), vim.eval("g:vira_user"), vim.eval("s:vira_pass_input"), vim.eval("g:vira_skip_cert_verify"))

    " Check if Vira connected to the server
    if (s:vira_is_init != 1)
      " Inform user with possible errors and reset unconfigured information
      echoe "Could not log into jira! Check authentication details or try entering CAPTCHA through web interface."
    endif
  endif

  " Clear password
  let s:vira_pass_input = ""

  " Set connection state
  let s:vira_is_connect = 1
endfunction

function! vira#_filter(name) "{{{2
  silent! execute 'python3 vira_set_' . a:name . '("' . 'g:vira_active_' . a:type . '")'
endfunction

function! vira#_get_active_issue() "{{{2
  return g:vira_active_issue
endfunction

function! vira#_get_menu(type) " {{{2
  if a:type == 'servers'
    " TODO-MB [191128] - no if statement required
    return execute('python3 Vira.get_' . a:type . '()')
  else
    return execute('python3 Vira.api.get_' . a:type . '()')
  endif
endfunction

function! vira#_get_statusline() "{{{2
  return g:vira_active_issue
  python3 vim.exec("let s:vira_statusline = " . vira_statusline())
endfunction

function! vira#_get_version() "{{{2
  return s:vira_version
endfunction

function! vira#_init() "{{{2
  " Load Vira python code and read user-configuration files
  silent! python3 import sys
  silent! exe 'python3 sys.path.append(f"' . s:vira_root_dir . '/python")'
  silent! python3 import Vira
endfunction

function! vira#_init_old() "{{{2
  if s:vira_is_init == 1
    return
  endif

  " Init flag
  let s:vira_is_init = 1

  " Init virarc
  silent! call vira#_update_virarc()

  " Init python
  call vira#_init_python()

  " Connect if vira_serv already set
  if exists('g:vira_serv') && g:vira_serv != ''
    call vira#_connect()
  endif

endfunction

function! vira#_init_python() "{{{2
  " Load Vira python code and read user-configuration files
  silent! python3 import sys
  silent! exe 'python3 sys.path.append(f"' . s:vira_root_dir . '/python")'
  silent! python3 import Vira
  silent! python3 exe 'python3 Vira.read_config("' . g:vira_config_servers_file . '")'
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

function! vira#_print_report(list) " {{{2
  " Write report output into buffer
  silent! redir @x>
  silent! execute 'python3 print(Vira.api.get_report())'
  silent! redir END
  silent! put x
endfunction

function! vira#_print_menu(list) " {{{2
  " Write menu output
  " execute ':normal! o' . list . "\<esc>"
  if (a:list->type() == type([]))
    for line in a:list
      execute ':normal! o' . line . "\<esc>"
    endfor
  else
    execute ':normal! o' . a:list . "\<esc>"
  endif
endfunction

function! vira#_menu(type) " {{{2
  call vira#_init_old()

  if a:type == 'servers' || s:vira_is_connect == 1
    " Get the current winnr of the 'vira_menu' or 'vira_report' buffer    " l:asdf ===
    if a:type == 'report'
      let type = 'report'
      let list = ''
    else
      let type = 'menu'
      echo a:type
      let list = vira#_get_menu(a:type)
    endif
    silent! let winnr = bufwinnr('^' . 'vira_' . type . '$')

    " Toggle/create the report buffer
    if (winnr < 0)
      " Open buffer into a window
      if type == 'report'
        silent! execute 'botright vnew ' . fnameescape('vira_' . type)
      else
        silent! execute 'botright new ' . fnameescape('vira_' . type)
        silent! execute 'resize 7'
      endif
      silent! setlocal buftype=nowrite bufhidden=wipe noswapfile nowrap nonumber nobuflisted
      silent! redraw
      silent! execute 'au BufUnload <buffer> execute bufwinnr(' . bufnr('#') . ') . ''wincmd w'''

      " TODO: VIRA-46 [190927] - Make the fold and line numbers only affect the window type {{{
      " Remove folding and line numbers from the report
      silent! let &foldcolumn=0
      silent! set relativenumber!
      silent! set nonumber
      " }}}

      " TODO: VIRA-80 [190928] - Move mappings to ftplugin {{{
      " Key mapping
      silent! execute 'nnoremap <silent> <buffer> <cr> 0:call vira#_set_' . a:type . '()<cr>:q!<cr>'
      silent! execute 'nnoremap <silent> <buffer> k gk'
      silent! execute 'nnoremap <silent> <buffer> q :q!<CR>'
      silent! execute 'vnoremap <silent> <buffer> j gj'
      silent! execute 'vnoremap <silent> <buffer> k gk'
      " }}}

      " Clean-up existing report buffer
      silent! normal ggVGd

      " Write report output into buffer
      if type == 'menu'
        call vira#_print_menu(list)
      else
        call vira#_print_report(list)
      endif

      " Clean-up extra output and remove blank lines
      silent! execute '%s/\^M//g'
      silent! normal GV3kzogg
      silent! execute 'g/^$/d'

      " Ensure wrap and linebreak are enabled
      silent! execute 'set wrap'
      silent! execute 'set linebreak'
    else
      silent! execute winnr .'wincmd q'
      if type == 'menu'
        call vira#_menu(a:type)
      endif
    endif
  else
    silent! execute winnr .'wincmd q'
    call vira#_menu("servers")
  endif
endfunction

function! vira#_quit() "{{{2
  let vira_windows = ['menu', 'report']
  for vira_window in vira_windows
    let winnr = bufwinnr('^' . 'vira_' . vira_window . '$')
    if (winnr > 0)
        execute winnr .' wincmd q'
    endif
  endfor
endfunction

function! vira#_reset_filters() " {{{2
  for vira_filter in s:vira_filters
    silent! call vira#_reset_filter(vira_filter)
  endfor
endfunction

function! vira#_reset_filter(variable) "{{{2
  execute 'let g:vira_active_' . a:variable . ' = g:vira_default_' . a:variable . '"'
endfunction

function! vira#_set_filter(variable, type) "{{{2
  " TODO: VIRA-27 [191008] - New filter function remove old calls and replace with variables
  execute 'normal 0'

  if a:type == '<cWORD>'
    let value = expand('<cWORD>')
  else
    let value = getline('.')
  endif
  execute 'let ' . a:variable . ' = "' . value . '"'

  if a:variable == 'g:vira_serv'
    call vira#_connect()
  endif
endfunction

function! vira#_set_issues() "{{{2
  call  vira#_set_filter('g:vira_active_issue', '<cWORD>')
endfunction

function! vira#_set_projects() "{{{2
  call  vira#_set_filter('g:vira_project', '<cWORD>')
endfunction

function! vira#_set_servers() "{{{2
  call  vira#_set_filter('g:vira_serv', '<cWORD>')
endfunction

function! vira#_set_statuses() "{{{2
  call  vira#_set_filter('g:vira_active_status', '.')
endfunction

function! vira#_set_assignees() "{{{2
  call  vira#_set_filter('g:vira_active_assignee', '.')
endfunction

function! vira#_set_priorities() "{{{2
  call  vira#_set_filter('g:vira_active_priority', '.')
endfunction

function! vira#_set_reporters() "{{{2
  call  vira#_set_filter('g:vira_active_reporter', '.')
endfunction

function! vira#_set_issuetypes() "{{{2
  call  vira#_set_filter('g:vira_active_issuetype', '.')
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
