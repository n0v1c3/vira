" File: autoload/vira.vim {{{1
" Description: Internals and API functions for vira
" Authors:
"   n0v1c3 (Travis Gall) <https://github.com/n0v1c3>
"   mikeboiko (Mike Boiko) <https://github.com/mikeboiko>
" Version: 0.0.1

" Variables {{{1
let s:vira_version = '0.0.1'
let s:vira_connected = 0

let s:vira_statusline = g:vira_null_issue
let s:vira_start_time = 0
let s:vira_end_time = 0

let s:vira_root_dir = fnamemodify(resolve(expand('<sfile>:p')), ':h') . '/..'

let s:vira_menu_type = ''
  
let s:vira_select_init = 0
let s:vira_filter = ''
let s:vira_filter_hold = @/

let s:vira_todo_header = 'TODO'
let s:vira_prompt_file = '/tmp/vira_prompt'
let s:vira_set_lookup = {
      \'assign_issue': 'assign_issue',
      \'assignees': 'assignee',
      \'components': 'component',
      \'issues': 'g:vira_active_issue',
      \'servers': 'g:vira_serv',
      \'issuetypes': 'issuetype',
      \'priorities': 'priority',
      \'projects': 'project',
      \'reporters': 'reporter',
      \'statusCategories': 'statusCategory',
      \'statuses': 'status',
      \'set_status': 'transition_issue',
      \'versions': 'fixVersion',
      \}

" AutoCommands {{{1
augroup ViraPrompt
  autocmd!
  exe 'autocmd BufWinLeave ' . s:vira_prompt_file . ' call vira#_prompt_end()'
augroup END

" Functions {{{1
function! vira#_browse() "{{{2
  " Confirm an issue has been selected
  if (vira#_get_active_issue() == g:vira_null_issue)
      echo "Please select an issue first"
      return
  endif

  " Create url path from server and issue key
  let l:url = g:vira_serv . '/browse/' . vira#_get_active_issue()

  " Set browser - either user defined or $BROWSER
  if exists('g:vira_browser')
    let l:browser = g:vira_browser
  else | let l:browser = $BROWSER | endif

  " User needs to define a browser
  if l:browser == ''
    echoerr 'Please set $BROWSER environment variable or g:vira_browser vim variable before running :ViraBrowse'
    return
  endif

  " Open current issue in browser
  execute 'term ++close ' . l:browser . ' "' . l:url . '"'

endfunction

function! vira#_prompt_start(type) "{{{2

  " Make sure vira has all the required inputs selected
  if a:type == 'comment'
    if (vira#_get_active_issue() == g:vira_null_issue)
      echo "Please select an issue before commenting"
      return
    endif
  endif

  let prompt_text = execute('python3 print(Vira.api.get_prompt_text("'.a:type.'"))')[1:-2]
  call writefile(split(prompt_text, "\n", 1), s:vira_prompt_file)
  execute 'sp ' . s:vira_prompt_file
  silent! setlocal spell
  1

endfunction

function! vira#_prompt_end() "{{{2
  " Write contents of the prompt buffer to jira server

  let g:vira_input_text = trim(join(readfile(s:vira_prompt_file), "\n"))

  if (g:vira_input_text  == "")
    redraw | echo "No vira actions performed"
  else
    python3 Vira.api.write_jira()
    call vira#_refresh()
  endif

endfunction

function! vira#_check_project(type) abort "{{{2
  " Check if project was selected for
  " components and versions

  if a:type != 'components' && a:type != 'versions'
    return 1
  endif

  if (execute('python3 print(Vira.api.userconfig_filter["project"])')[1:] == "")
    return 0
  endif

  return 1

endfunction

function! vira#_connect() abort "{{{2
  " Connect to jira server if not connected already

  if (!exists('g:vira_serv') || g:vira_serv == '' || s:vira_connected == 1)
    return
  endif

  " Neovim requires this when trying to run vira from a brand new empty buffer
  python3 import vim

  python3 Vira.api.connect(vim.eval("g:vira_serv"))
  let s:vira_connected = 1

endfunction

function! vira#_get_active_issue() "{{{2
  return g:vira_active_issue
endfunction

function! vira#_get_statusline() "{{{2
  return g:vira_active_issue
  " python3 vim.exec("let s:vira_statusline = " . vira_statusline())
endfunction

function! vira#_get_version() "{{{2
  return s:vira_version
endfunction

function! vira#_init_python() "{{{2
  " Load Vira python code and read user-configuration files
  silent! python3 import sys
  silent! exe 'python3 sys.path.append(f"' . s:vira_root_dir . '/python")'
  silent! python3 import Vira
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
  if (type(a:list) == type([]))
    for line in a:list
      execute ':normal! o' . line . "\<esc>"
    endfor
  else | execute ':normal! o' . a:list . "\<esc>" | endif
endfunction

function! vira#_load_project_config() " {{{2

  " Save current directory and switch to file direcotry
  let s:current_dir = getcwd()
  cd %:p:h

  " Load project configuration for the current git repo
  python3 Vira.api.load_project_config()

  " Return to current directory
  cd `=s:current_dir`

  " Disable loading of project config
  let g:vira_load_project_enabled = 0

endfunction

function! vira#_menu(type) abort " {{{2

  " Load config from user-defined file
  if (g:vira_load_project_enabled == 1)
    call vira#_load_project_config()
  endif

  " User to select jira server and connect to it if not done already
  if (!exists('g:vira_serv') || g:vira_serv == '') && a:type != 'servers'
    call vira#_menu('servers')
    return
  endif
  call vira#_connect()

  " Get the current winnr of the 'vira_menu' or 'vira_report' buffer    " l:asdf ===
  if a:type == 'report'
    if (vira#_get_active_issue() == g:vira_null_issue)
      call vira#_menu('issues') 
      return 
    endif
    let type = 'report'
    let list = ''
  elseif a:type == 'text'
    execute 'python3 Vira.api.userconfig_filter["text"] = "' . input('text ~ ') . '"'
    return
  else
    if !vira#_check_project(a:type)
      echo 'Please select a project before applying this filter.'
      return
    endif
    let type = 'menu'
    let list = execute('python3 Vira.api.get_' . a:type . '()')
    
    " Save current menu type
    let s:vira_menu_type = a:type
  endif

  silent! let winnr = bufwinnr('^' . 'vira_' . type . '$')
  " Toggle/create the report buffer
  if (winnr >= 0)
    silent! execute winnr .'wincmd q'
    return
  endif

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

  " TODO: VIRA-46 [190927] - Make the fold and line numbers only affect the window type
  " Remove folding and line numbers from the report
  silent! let &foldcolumn=0
  silent! set relativenumber!
  silent! set nonumber

  " Clean-up existing report buffer
  silent! normal ggVGd

  " Write report output into buffer
  if type == 'menu'
    let s:vira_filter = ''
    let s:vira_filter_hold = @/
    call vira#_print_menu(list)
  else | call vira#_print_report(list) | endif

  " Clean-up extra output and remove blank lines
  silent! execute '%s/\^M//g'
  silent! normal gg2dd
  silent! normal GV3kzogg
  " silent! execute 'g/^$/d'
  silent! execute 'g/\n\n\n/\n\n/g'

  " Ensure wrap and linebreak are enabled
  if type == 'menu' | silent execut 'set nowrap'
  else | silent! execute 'set wrap'
  endif
  silent! execute 'set linebreak'
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

function! vira#_refresh() " {{{2
  let vira_windows = ['menu', 'report']
  for vira_window in vira_windows
    let winnr = bufwinnr('^' . 'vira_' . vira_window . '$')
    if (winnr > 0)
        execute winnr .' wincmd q'
        if (vira_window == 'report') | call vira#_menu(vira_window)
        else | call vira#_menu(s:vira_menu_type)
        endif
    endif
  endfor
endfunction

function! vira#_reset_filters() " {{{2
  python3 Vira.api.reset_filters()
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

" Filter {{{1
function! vira#_filter(name) "{{{2
  silent! execute 'python3 vira_set_' . a:name . '("' . 'g:vira_active_' . a:type . '")'
endfunction

function! vira#_getter() "{{{2
  " Return the proper form of the selected data
  if s:vira_menu_type == 'issues' || s:vira_menu_type == 'projects' || s:vira_menu_type == 'set_servers'
    return expand('<cWORD>')
  endif
  return getline('.')
endfunction

function! vira#_select() "{{{2
  execute 'normal mm'
  execute 'normal 0'
  call feedkeys(":set hlsearch\<cr>")

  let value = vira#_getter()

  if s:vira_select_init == 1
    let s:vira_highlight = s:vira_highlight . "|" . value
    let s:vira_filter = s:vira_filter . "," . '"' . value . '"'
  else
    let s:vira_highlight = value
    let s:vira_filter = '"' . value . '"'
    let s:vira_select_init = 1
  endif
  let @/ = '\v' . s:vira_highlight
  execute "normal! /\\v" . s:vira_highlight . "\<cr>"
  execute 'normal `m'
  call feedkeys(":echo '" . s:vira_highlight . "'\<cr>")
endfunction

function! vira#_set() "{{{2
  " This function is used to set vim and python variables
  execute 'normal 0'

  let value = vira#_getter()
  let g:testvar = value
  let variable = s:vira_set_lookup[s:vira_menu_type]
  
  if ((variable == 'assignee' || variable == 'reporter') && value != "Unassigned")
    let value =  split(value,' \~ ')[1]
  endif

  if variable[:1] == 'g:'
    execute 'let ' . variable . ' = "' . value . '"'
    if variable == 'g:vira_serv'
      " Reset connection and clear filters before selecting new server
      call vira#_reset_filters()
      python3 Vira.api.userconfig_filter["project"] = ""
      let s:vira_connected = 0
      call vira#_connect()
    endif
  
  elseif variable == 'assign_issue' || variable == 'transition_issue'
    execute 'python3 Vira.api.jira.' . variable . '(vim.eval("g:vira_active_issue"), "' . value . '")'

  else
    if s:vira_filter[:0] == '"'
      let value = substitute(s:vira_filter,'|',', ','')
    else | let value = '"' . value . '"' | endif

    execute 'python3 Vira.api.userconfig_filter["' . variable . '"] = '. value .''

    if variable == 'status'
      execute 'python3 Vira.api.userconfig_filter["statusCategory"] = ""'
    endif
    " call vira#_menu('issues')
  endif

  call vira#_filter_reset()
endfunction

function! vira#_filter_reset()
  let s:vira_select_init = 0
  let @/ = s:vira_filter_hold
endfunction
