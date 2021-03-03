" File: autoload/vira.vim {{{1
" Description: Internals and API functions for vira
" Authors:
"   n0v1c3 (Travis Gall) <https://github.com/n0v1c3>
"   mikeboiko (Mike Boiko) <https://github.com/mikeboiko>

" Variables {{{1
let s:vira_version = '0.4.5'
let s:vira_connected = 0

let s:vira_statusline = g:vira_null_issue
let s:vira_start_time = 0
let s:vira_end_time = 0

let s:vira_root_dir = resolve(fnamemodify(resolve(expand('<sfile>:p')), ':h') . '/..')

let s:vira_menu_type = ''

let s:vira_filter = ''
let s:vira_filter_hold = @/
let s:vira_filter_setkey = 0
let s:vira_highlight = ''
let s:projects = []
let s:versions = []

let s:vira_async_timer = g:vira_async_init_timer
let s:vira_async_debug = 0

let s:vira_todo_header = 'TODO'
let s:vira_prompt_file = s:vira_root_dir . '/.vira_prompt'
let s:vira_set_lookup = {
      \'assign_issue': 'assign_issue',
      \'assignees': 'assignee',
      \'components': 'component',
      \'issues': 'g:vira_active_issue',
      \'issuetypes': 'issuetlpe',
      \'priority': 'priorities',
      \'priorities': 'priority',
      \'projects': 'project',
      \'reporters': 'reporter',
      \'servers': 'g:vira_serv',
      \'set_status': 'transition_issue',
      \'version': 'fixVersions',
      \'statusCategories': 'statusCategory',
      \'statuses': 'status',
      \'epic': "customfield_10014",
      \'epics': "'Epic Link'",
      \'versions': 'fixVersion',
      \'issuetype': 'issuetypes',
      \'component': 'components',
      \}

" AutoCommands {{{1
augroup ViraPrompt "{{{2
  autocmd!
  exe 'autocmd BufWinLeave ' . s:vira_prompt_file . ' call vira#_prompt_end()'
augroup END

" Functions {{{1
function! vira#_async() abort "{{{2
  try
    python3 Vira.api._async(Vira.api._async_vim)
  endtry
  if s:vira_async_debug | echo s:versions | endif
  call timer_start(s:vira_async_timer, { -> execute('call vira#_async()', '') })
endfunction

function! vira#_browse(url) "{{{2
  " Confirm an issue has been selected
  if (vira#_get_active_issue() == g:vira_null_issue)
      echo "Please select an issue first"
      return
  endif

  " Set browser - either user defined or $BROWSER
  if exists('g:vira_browser') | let l:browser = g:vira_browser
  elseif exists('$BROWSER') | let l:browser = $BROWSER
  elseif executable('open') | let l:browser = 'open'
  elseif executable('xdg-open') | let l:browser = 'xdg-open'
  else
    echoerr 'Please set $BROWSER environment variable or g:vira_browser vim variable before running :ViraBrowse'
  endif

  " There is no guarantee that the command provided by the user exists and is executable; if it's not provide an
  " informative error as to why we can't open the current issue in the browser.
  if l:browser != 'open' && l:browser != 'xdg-open' && !executable(l:browser)
    echoerr "The browser '" . l:browser . "' does not exist or is not executable"
  endif

  " Open current issue in browser
  silent! call execute('!' . l:browser . ' "' . a:url . '" > /dev/null 2>&1 &')
  redraw!
endfunction

function! vira#_msg_error(code, msg) "{{{2
  echohl ErrorMsg
  echo 'VIRA ERROR [' . a:code . '] - ' . a:msg
  echohl None
endfunction

silent! function! vira#_prompt_start(type, ...) abort "{{{2
  " Make sure vira has all the required inputs selected
  if a:type != 'issue' && a:type != 'edit_filter'
    if (vira#_get_active_issue() == g:vira_null_issue)
      echo 'Please select an issue before performing this action'
      return
    endif
  endif

  " Used for comment id
  if a:0 > 0
    let comment_id = a:1
  else
    let comment_id = ''
  end

  let prompt_text = execute('python3 print(Vira.api.get_prompt_text("'.a:type.'", '.comment_id.'))')[1:-1]
  call writefile(split(prompt_text, "\n", 1), s:vira_prompt_file)
  execute 'sp ' . s:vira_prompt_file
  silent! setlocal buftype=
  silent! setlocal spell
  silent! setlocal wrap
endfunction

function! vira#_prompt_end() "{{{2
  " Write contents of the prompt buffer to jira server
  let g:vira_input_text = trim(join(readfile(s:vira_prompt_file), "\n"))
  python3 Vira.api.set_prompt_text()
  call vira#_refresh()
endfunction

function! vira#_check_project(type) abort "{{{2
  " Check if project was selected for components and versions
  if a:type != 'components' " && a:type != 'versions'
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

  " TODO: VIRA-222 [200930] - remove extra inputs
  if (g:vira_serv == 'Null')
      let g:vira_serv = input("server: ")
      let g:vira_serv = input("server: ")
  endif

  " Neovim requires this when trying to run vira from a brand new empty buffer
  python3 import vim
  python3 Vira.api.connect(vim.eval("g:vira_serv"))
  let s:vira_connected = 1
  call vira#_async()
endfunction

function! vira#_edit_report() abort "{{{2
  " Edit the report field matching to cursor line
  try
    let set_command = execute('python3 print(Vira.api.report_lines['.line('.').'])')[1:-1]
    silent! execute set_command
  catch
    echo 'This field can not be changed.'
  endtry
endfunction

function! vira#_get_active_issue() "{{{2
  return g:vira_active_issue
endfunction

function! vira#_get_statusline() "{{{2
  return g:vira_active_issue
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

function! vira#_load_project_config(...) " {{{2
  " Save current directory and switch to file directory
  let s:current_dir = getcwd()
  cd %:p:h

  if a:0 > 0
    let vira_repo  = a:1
  else
    let vira_repo   = ''
  end
  let old_server = get(g:, 'vira_serv', '')

  " Load project configuration for the current git repo
  call vira#_reset_filters()
  exe 'python3 Vira.api.load_project_config("'.vira_repo.'")'

  " Return to current directory
  cd `=s:current_dir`

  " Disable loading of project config
  let g:vira_load_project_enabled = 0

  " Handle changing servers
  if old_server != get(g:, 'vira_serv', '')
    let s:vira_connected = 0
    call vira#_connect()
  endif

endfunction

function! vira#_menu(type) abort " {{{2
  if a:type != 'servers'
    " Load config from user-defined file
    if (g:vira_load_project_enabled == 1) | call vira#_load_project_config() | endif
    " User to select jira server and connect to it if not done already
    if (!exists('g:vira_serv') || g:vira_serv == '')
      call vira#_menu('servers')
      return
    endif
  endif

  " Get the current winnr of the 'vira_menu' or 'vira_report' buffer
  if a:type == 'report'
    if (vira#_get_active_issue() == g:vira_null_issue)
      call vira#_menu('issues')
      return
    endif
    let type = 'report'
    let list = ''
  elseif a:type == 'text'
    let value = input('text ~ ')
    execute 'python3 Vira.api.userconfig_filter["text"] = "' . value . '"'
    if value != ''
        silent! call feedkeys(":set hls\<cr>")
        let value = substitute(value, ' ', '|', 'g')
        silent! execute "normal! /" . value . '\<cr>'
        let @/ = '\v' . value
    endif
    call vira#_refresh() " Refresh open menus
    return
  else
    if !vira#_check_project(a:type)
      echo 'Please select a project before applying this filter.'
      return
    endif
    let type = 'menu'
    if a:type == 'versions' || a:type == 'projects' | let printer = 'print_'
    else | let printer = 'get_' | endif
    let list = execute('python3 Vira.api.' . printer . a:type . '()')

    " Save current menu type
    let s:vira_menu_type = a:type
  endif

  " Open buffer into a window
  silent! let winnr = bufwinnr(s:vira_root_dir . '/vira_' . type . '$')
  if type == 'report'
    if (winnr <= 0)
      if g:vira_report_width == 'l' || g:vira_report_width == 'L'
        autocmd BufEnter vira_report silent! wincmd L
      elseif g:vira_report_width == 'h' || g:vira_report_width == 'H'
        autocmd BufEnter vira_report silent! wincmd H
      elseif g:vira_report_width == 't' || g:vira_report_width == 'T'
        autocmd BufEnter vira_report silent! wincmd T
      elseif g:vira_report_width > 0
        autocmd BufEnter vira_report setlocal winfixwidth
        silent! execute 'vertical resize ' . g:vira_report_width
      endif
      silent! execute 'botright vnew ' . fnameescape(s:vira_root_dir . '/vira_' . type)
    else | call execute(winnr . ' windo e') | endif
  else " Menus
    if (winnr <= 0)
      if g:vira_menu_height == 'j' || g:vira_menu_height == 'J' | let g:vira_menu_height = 10 | endif
      if g:vira_menu_height == 't' || g:vira_menu_height == 'T' || g:vira_menu_height == 0
        autocmd BufEnter vira_menu silent! wincmd T
      endif
      silent! execute 'botright new ' . fnameescape(s:vira_root_dir . '/vira_' . type)
      if g:vira_menu_height != 't' && g:vira_menu_height != 'T' && g:vira_menu_height != 0
        execute 'resize ' . g:vira_menu_height
      endif
    else | call execute(winnr . ' windo e') | endif
  endif

  silent! redraw
  silent! execute 'au BufUnload <buffer> execute bufwinnr(' . bufnr('#') . ') . ''wincmd w'''

  " Clean-up existing report buffer
  execute winnr . ' wincmd "' . execute("normal! ggVGd") . '"'

  " Write report output into buffer
  if type == 'menu'
    let s:vira_filter = ''
    let s:vira_highlight = ''
    call vira#_filter_unload()
    call vira#_highlight_reload()
    silent! put=list
  else | call vira#_print_report(list) | endif

  " Clean-up extra output and remove blank lines
  if a:type != 'text'
      silent! execute '%s/\^M//g' | call histdel("search", -1)
      silent! 1,2d x
      silent! execute 'g/\n\n\n/\n\n/g' | call histdel("search", -1)
      silent! normal zCGVzOgg
  endif

  " Ensure wrap and linebreak are enabled
  if type == 'menu' | silent execute 'set nowrap'
  else | silent! execute 'set wrap' | endif

  silent! execute 'set linebreak'
endfunction

function! vira#_quit() "{{{2
  let vira_windows = ['menu', 'report']
  for vira_window in vira_windows
    let winnr = bufwinnr(s:vira_root_dir . '/vira_' . vira_window . '$')
    if (winnr > 0)
        silent! execute winnr . ' wincmd q'
    endif
  endfor
  silent! call vira#_resize()
endfunction

function! vira#_refresh() " {{{2
  let vira_windows = ['menu', 'report']
  for vira_window in vira_windows
    let winnr = bufwinnr(s:vira_root_dir . '/vira_' . vira_window . '$')
    if (winnr > 0)
      if (vira_window == 'report')
        silent! call vira#_menu(vira_window)
      else | call vira#_menu(s:vira_menu_type) | endif
      execute 'silent! set syntax=vira_' . vira_window
    endif
  endfor
endfunction

function! vira#_reset_filters() " {{{2
  python3 Vira.api.reset_filters()
endfunction

function! vira#_resize() " {{{2
  let vira_windows = ['menu', 'report']
  for vira_window in vira_windows
    let winnr = bufwinnr(s:vira_root_dir . '/vira_' . vira_window . '$')
      if (vira_window == 'report') | silent! execute "normal! h:vnew\<cr>:q\<cr>l"
      else | silent! execute "normal! h:new\<cr>:q\<cr>l"
      endif
  endfor
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
      python3 Vira.api.jira.add_comment(vim.eval('vira#_get_active_issue()'), vim.eval('file_path . "\n*" . s:vira_todo_header . "* " . comment'))
    endif

    " Vim comment
    let current_pos = getpos('.')
    execute "normal! O" . comment_header . comment . "\<esc>"
    call setpos('.', current_pos)
    call NERDComment(0, "Toggle")
  endif
endfunction

function! vira#_todos() "{{{2
  " Binary files that can be ignored
  set wildignore+=*.jpg,*.docx,*.xlsm,*.mp4,*.vmdk
  " Search the CWD to find all of your current TODOs
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

function! vira#_filter_all(mode) "{{{2
  " Un/select all items in current menu
  let type = s:vira_menu_type
  if type == 'component' || type == 'version'
    let offset = 1
  else | let offset = 0 | endif
  let current_pos = getpos('.')
  silent! execute '1' . ',' . (line('$') - offset) . 'call vira#_' . a:mode . '()'
  echo s:vira_highlight
  call setpos('.', current_pos)
endfunction

function! vira#_filter_unload() " {{{2
  if s:vira_filter_setkey != 1
    let save_pos = getpos('.')
    silent! execute "normal! /" . histget('search', -1) . "\<cr>"
    let @/ = histget('search', -1)
    call setpos('.', save_pos)
    let s:vira_filter_setkey = 1
  endif
endfunction

function! vira#_filter_load() " {{{2
    if s:vira_filter_setkey != 0 && s:vira_highlight != ''
        let s:vira_filter_hold = @/
        silent! call vira#_highlight()
        let s:vira_filter_setkey = 0
    endif
endfunction

function! vira#_getter() "{{{2
    let line = getline('.')
    let lineSplit = split(line,' \~ ')
    let type = s:vira_menu_type

    " Return the proper form of the selected data
    if expand('%:t') == 'vira_report'
        return expand('<cWORD>')
    elseif type == 'epic' || type == 'epics' || type || type == 'issues' || type == 'projects' || type == 'set_servers'
        normal! 0
        return expand('<cWORD>')
    elseif type == 'versions' || type == 'version'
      if line == 'None' | return line | endif
      return lineSplit[1]
    elseif type == 'assignees' || type == 'reporters'
      if line == 'Unassigned' | return line | endif
      return lineSplit[1]
    elseif type == 'assign_issue'
      if line == 'Unassigned' | return 'Unassigned' | endif
      return lineSplit[1]
    else | return line | endif
endfunction

function! vira#_select() "{{{2
  let current_pos = getpos('.')
  let value = vira#_getter()

  if expand('%:t') == 'vira_report'
      let issueTest = substitute(substitute(value,'(','','g'),')','','g')
      let issueTest = substitute(substitute(issueTest,'[','','g'),']','','g')
      let issueTest = substitute(substitute(issueTest,'{','','g'),'}','','g')
      let issueTest = substitute(issueTest,'│','','g')
    silent! if execute('python3 Vira.api.jira.search_issues("issue = ' . issueTest . '")') == ''
      let g:vira_active_issue = issueTest
      call vira#_menu('report')
    else
      call vira#_browse(expand('<cWORD>'))
    endif
  else
    call vira#_filter_load()
    if s:vira_highlight != '' && stridx(s:vira_highlight, '|' . value . '|') < 0
      if s:vira_menu_type == 'assign_issue' || s:vira_menu_type == 'epic' || s:vira_menu_type == 'issuetype' || s:vira_menu_type == 'set_status' || s:vira_menu_type == 'priority' || s:vira_menu_type == 'epic' || s:vira_menu_type == 'issues' || s:vira_menu_type == 'servers'
        let s:vira_highlight = '|' . value . '|'
      else | let s:vira_highlight = s:vira_highlight . value . '|' | endif
    elseif s:vira_highlight == ''
      let s:vira_highlight = '|' . value . '|'
    endif
    call vira#_highlight()
    call setpos('.', current_pos)
  endif
endfunction

function! vira#_unselect() "{{{2
  let current_pos = getpos('.')

  let value = vira#_getter()
  let s:vira_highlight = substitute(s:vira_highlight,'|'.value.'|','|','g')
  let length = len(s:vira_highlight)
  if expand('%:t') == 'vira_report'
    silent! undo
    silent! undo
    let line = line('.')
    execute 2
    let g:vira_active_issue = split(getline('.')[4:],' ')[0]
    execute line
  elseif s:vira_highlight[1:2] == '||' || s:vira_highlight == '|' || s:vira_highlight[length-1:] != '|'
    let s:vira_filter_setkey = 0
    silent! call vira#_filter_unload()
    let s:vira_filter = ''
    let s:vira_highlight = ''
    echo s:vira_highlight
  else
    call vira#_highlight()
  endif

  call setpos('.', current_pos)
endfunction

function! vira#_highlight() "{{{2
  let type = s:vira_menu_type
  if type == 'epic' || type == 'epics' || type == 'issues' || type == 'versions' || type == 'version'
      let end_line = '' | let end_seperator = ''
  else | let end_line = '\n' | let end_seperator = '$' | endif

  if type == 'assign_issue' || type == 'assignees' || type == 'reporters' || type == 'versions' || type == 'version'
    let seperator = ''
  else | let seperator = '^' | endif

  " echo s:vira_highlight

  let s:vira_highlight = substitute(s:vira_highlight,"\\\\\\\.","\\.",'g')
  let s:vira_highlight = substitute(s:vira_highlight,"\\\.","\\\\\\.",'g')
  let @/ = '\v' . seperator . substitute(s:vira_highlight[1:len(s:vira_highlight)-2],'|', end_seperator . '|' . seperator,'g') . end_seperator . end_line

  let s:vira_highlight = substitute(s:vira_highlight,"\\\\\\\.","\\.",'g')
  let s:vira_filter = '"' . substitute(s:vira_highlight[1:len(s:vira_highlight)-2],'|','","','g') . '"'
endfunction

function! vira#_highlight_reload() "{{{2
    if s:vira_menu_type != 'epic' && s:vira_menu_type != 'assign_issue' && s:vira_menu_type != 'component' && s:vira_menu_type != 'priority' && s:vira_menu_type != 'set_status' && s:vira_menu_type != 'version' && s:vira_menu_type != 'issuetype'
        call vira#_filter_load()
        if s:vira_menu_type == 'issues'
            let s:vira_highlight = '|' . g:vira_active_issue
        elseif s:vira_menu_type == 'servers'
            if exists('g:vira_serv') && g:vira_serv != ''
                let s:vira_highlight = '|' . g:vira_serv
            else | let s:vira_highlight = '' | endif
        else
            let s:vira_highlight = execute('python3 print(Vira.api.userconfig_filter["'.s:vira_set_lookup[s:vira_menu_type].'"])')
        endif
        let s:vira_highlight = substitute('|' . s:vira_highlight[1:] . '|',"(",'','g')
        let s:vira_highlight = substitute(s:vira_highlight,"]",'','g')
        let s:vira_highlight = substitute(s:vira_highlight,"[",'','g')
        let s:vira_highlight = substitute(s:vira_highlight,")",'','g')
        let s:vira_highlight = substitute(s:vira_highlight,', ','|','g')
        let s:vira_highlight = substitute(s:vira_highlight,"'",'','g')
        let s:vira_highlight = substitute(s:vira_highlight,"\\\\\\\.","\\.",'g')
        if len(s:vira_highlight) <= 2
            let s:vira_highlight = ''
        else | call vira#_highlight() | endif
    endif
endfunction

function! vira#_set() "{{{2
    " This function is used to set vim and python variables
    execute 'normal! 0'

    let value = vira#_getter()
    let variable = s:vira_set_lookup[s:vira_menu_type]

    " TODO: VIRA-239 [201027] - Flip menu selects for nice user highlights
    " Grab proper user id for `currentUser` lookup
    let currentUser = split(getline('.'),' \~ ')[0]

    " GLOBAL
    if variable[:1] == 'g:'
        execute 'let ' . variable . ' = "' . value . '"'
        if variable == 'g:vira_serv'
            " Reset connection and clear filters before selecting new server
            call vira#_reset_filters()
            python3 Vira.api.userconfig_filter["project"] = ""
            let s:vira_connected = 0
            call vira#_connect()
        endif

    " SET
    elseif variable == 'issuetypes' || variable == 'priorities'
        execute 'silent! python3 Vira.api.jira.issue("' . g:vira_active_issue . '").update(' . s:vira_menu_type . '={"name":"' . value . '"})'
    elseif variable == 'fixVersions' || variable == 'components'
        let value = s:vira_filter
        if value == '"None"' | let value = '{}'
        elseif value[:0] == '"' | let value = '{"name":' . substitute(s:vira_filter,'","', '"}, {"name": "', 'g') . '}'
        else | let value =  '{"name":"' . value . '"}'| endif
        execute 'silent! python3 Vira.api.jira.issue("' . g:vira_active_issue . '").update(fields={"' . variable . '":[' . value . ']})'
    elseif s:vira_menu_type == 'epic'
        if value != "None" | let value = '"' . value . '"' | endif
        let variable = s:vira_epic_field
        execute 'python3 Vira.api.jira.issue("' . g:vira_active_issue . '").update(fields={"' . variable . '":' . value . '})'
    elseif variable == 'transition_issue' || (variable == 'assign_issue' && !execute('silent! python3 Vira.api.jira.issue("'. g:vira_active_issue . '").update(assignee={"id": "' . substitute(value, 'currentUser', currentUser, '') . '"})'))
        let value = substitute(value, 'currentUser', currentUser, '')
        let value = substitute(value, 'Unassigned', '-1', '')
        execute 'silent! python3 Vira.api.jira.' . variable . '(vim.eval("g:vira_active_issue"), "' . value . '")'

    " FILTER
    else
        if s:vira_filter[:0] == '"'
          let value = substitute(s:vira_filter,'|',', ','')
        else | let value = '"' . value . '"' | endif
        execute 'python3 Vira.api.userconfig_filter["' . variable . '"] = ' . value
        if variable == 'status' | execute 'python3 Vira.api.userconfig_filter["statusCategory"] = ""' | endif
    endif

    if variable == 'project' | execute 'python3 Vira.api.get_version()' | endif

    call vira#_filter_closed()
endfunction

function! vira#_unset() "{{{2
    execute 'python3 Vira.api.userconfig_filter["' . s:vira_set_lookup[s:vira_menu_type] . '"] = ""'
    call vira#_filter_closed()
endfunction

function! vira#_filter_closed() "{{{2
    let s:vira_filter_setkey = 0
    let s:vira_highlight = ''
    let s:vira_filter = ''
    let s:vira_filter_hold = ''
    call vira#_filter_unload()
endfunction

function! vira#_toggle_hide() "{{{2
    let g:vira_version_hide = 1 - g:vira_version_hide
    call vira#_menu(s:vira_menu_type)
endfunction

" New {{{1
function! vira#_new(menu, name, project, description) "{{{2
  if a:menu == 'component'
    execute 'python3 Vira.api.new_' . a:menu . '("' . a:name . '","' . a:project . '")'
  else | execute 'python3 Vira.api.new_' . a:menu . '("' . a:name . '","' . a:project . '","' . a:description . '")'
  endif
endfunction
