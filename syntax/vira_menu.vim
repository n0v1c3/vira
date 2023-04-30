" Quit when a syntax file was already loaded.
if exists('b:vira_version') && b:vira_version == vira#_get_version() | finish | endif

" Menus {{{1
" General {{{2
syntax match viraMenusNull /\n*\s*\w\+/
syntax match viraMenusLink /^\s*\w\+\n/
syntax region viraMenus start=/.*\~.*/ end=/\n/ contains=viraMenusLink
syntax region viraMenusLink start=/\~.*/hs=s+1 end=/\n/ contained
highlight default link viraMenus Statement
highlight default link viraMenusLink Question
highlight default link viraMenusNull Question

" Versions {{{2
syntax region viraMenuV start=/.*\~.*\~.*/ end=/\n/ contains=viraMenuVName,viraMenuVProj
syntax region viraMenuVName start=/\~/hs=s+1 end=/\~/he=e-1 contained
syntax match viraMenuVProj /^\s*\w\+/ contained
highlight default link viraMenuV Statement
highlight default link viraMenuVName Question
highlight default link viraMenuVProj NonText

" Issues {{{2
syntax match viraIssuesIssue ".*-.* │.*│.*│.*│.*" nextgroup=viraIssuesDescription contains=viraIssuesDescription
syntax match viraIssuesDescription "│.*"hs=s+2 nextgroup=viraIssuesUsername contains=viraUsername,viraIssuesUsername,viraCode,viraCodeBrands contained
syntax match viraIssuesUsername " │.*" contains=viraDetailsTypeBug,viraDetailsTypeEpic,viraDetailsTypeStory,viraDetailsTypeTask,viraDetailsStatusInProgress,viraDetailsStatusTodo,viraDetailsStatusSelected,viraDetailsStatusDone,viraDetailsStatusComplete,viraDetailsStatusBacklog,viraIssuesStatus contained

highlight viraIssuesIssue ctermfg=186 guifg=#d7d787
highlight viraIssuesDescription ctermfg=108 guifg=#87af87
highlight viraIssuesUsername ctermfg=81 guifg=#5fd7ff cterm=bold gui=bold

" Servers {{{2
" syntax match viraHTML "https://.*"
" highlight default link viraHTML Question

" Style {{{2
" syntax match viraMenuStyle '.*' contains=viraBold contained
syntax match viraBold "\*.*\*" contained
syntax match viraBullets ".*\* " contained
syntax match viraCitvtion "??.*??" contained

" Brands {{{2
syntax match viraUsername "\[\~.*\]\|@\w\+" contained
highlight viraUsername ctermfg=81 guifg=#5fd7ff

highlight viraBold cterm=bold gui=bold
highlight default link viraBullets Identifier
highlight default link viraCitvtion Title

" syntax match viraCommentAuthor /.*@/hs=s,he=e contains=viraCommentDate nextgroup=viraCommentDate
" syntax region viraCommentClose start="}}" end="}"
" syntax match viraCommentDate /@.*/hs=s,he=e contained

" Details {{{2
syntax match viraDetails "│"
syntax match viraDetailsTypeBug "│ Bug "hs=s+2,he=e-1
syntax match viraDetailsTypeEpic "│ Epic "hs=s+2,he=e-1
syntax match viraDetailsTypeStory "│ Story "hs=s+2,he=e-1
syntax match viraDetailsTypeTask "│ Task "hs=s+2,he=e-1

syntax match viraDetailsStatusInProgress "In Progress │"he=e-2
syntax match viraDetailsStatusComplete "Complete   "he=e-3
syntax match viraDetailsStatusDone "Done   "he=e-3
syntax match viraDetailsStatusTodo "To Do   "he=e-3
syntax match viraDetailsStatusBacklog "Backlog   "he=e-3
syntax match viraDetailsStatusSelected "Selected for Development "he=e-1

syntax match viraDetailsHigh "High  "he=s+4
syntax match viraDetailsHighest "Highest  "he=s+7
syntax match viraDetailsLow "Low  "he=s+3
syntax match viraDetailsLowest "Lowest  "he=s+6
syntax match viraDetailsMedium "Medium  "he=s+6
" }}}

" Comments {{{2
syntax match viraItalic "_.*_"
syntax match viraLink "\[.*|.*\]"
syntax match viraMonospaced "{{.*}}"
" syntax match viraPhoto "\!.*|.*\!"
" syntax match viraStory "\v.*" contained
syntax match viraStrikethrough "-.*-"
syntax match viraSubscript "\~.*\~"
" syntax match viraTheLine "----"
" syntax match viraTitles "  .*-.*  \|Summary\|Description\|Comments\n"hs=s,he=e
" syntax match viraTitle "\%1l.*:" contained nextgroup=viraStory
" syntax match viraTitleComment /.*{{1/hs=s,he=e contains=viraTitleFold nextgroup=viraTitleFold
" syntax match viraTitleFold /{{.*/hs=s,he=e contained
syntax match viraUnderline "+.*+"
syntax region viraCode start=/`/ end=/`/
" syntax region viraCode start=/{code.*}/ end=/{code}/
syntax region viraNoformat start=/{noformat.*}/ end=/{noformat}/

" syntax match viraCodeBrands '\s\cVIRA\s\|\s\cVIM\s\|\s\cGIT\s\|\s\cNEOVIM\s\|\s\cNVIM\s\|\s\cJIRA\s\|\s\cGITHUB\s' contained
" syntax match viraCodeBrands '\s\cVIRA\.\|\s\cVIM\.\|\s\cGIT\.\|\s\cNEOVIM\.\|\s\cNVIM\.\|\s\cJIRA\.\|\s\cGITHUB\.'he=e-1 contained

" Highlighting {{{1
highlight viraCode ctermfg=3 guifg=#808000
highlight viraCodeBrands ctermfg=darkblue guifg=darkblue
" highlight default link viraCommentClose Statement
" highlight default link viraCommentDate Statement
" highlight default link viraDetailsA Identifier
" highlight default link viraDetailsB Identifier
" highlight default link viraDetailsC Identifier
" highlight default link viraDetailsD Normal
" highlight default link viraDetailsE Identifier
" highlight default link viraDetailsF Identifier
highlight default link viraDetails Identifier
highlight default link viraMonospaced Question
highlight default link viraNoformat Normal
" highlight default link viraPhoto Title
" highlight default link viraStory Identifier
highlight default link viraSubscript Question
" highlight default link viraTheLine Title
" highlight default link viraTitles Title
" highlight default link viraTitle Title
" highlight default link viraTitleComment Question
" highlight default link viraTitleDescription Question
" highlight default link viraTitleFold Statement
highlight default link viraDetailsTypeAssignee Statement
highlight default link viraDetailsTypeReporter Statement

highlight viraDetailsHigh ctermfg=red guifg=red
highlight viraDetailsHighest ctermfg=darkred guifg=darkred
highlight viraDetailsLow ctermfg=darkgreen guifg=darkgreen
highlight viraDetailsLowest ctermfg=green guifg=green
highlight viraDetailsMedium ctermfg=darkyellow guifg=darkyellow
highlight viraDetailsStatusComplete ctermbg=darkgreen ctermfg=white guibg=darkgreen guifg=white cterm=bold gui=bold
highlight viraDetailsStatusDone ctermbg=darkgreen ctermfg=white guibg=darkgreen guifg=white cterm=bold gui=bold
highlight viraDetailsStatusInProgress ctermbg=darkblue ctermfg=white guibg=darkblue guifg=white cterm=bold gui=bold
highlight viraDetailsStatusTodo ctermbg=251 ctermfg=0 guibg=#c6c6c6 guifg=#000000 cterm=bold gui=bold
highlight viraDetailsStatusBacklog ctermbg=251 ctermfg=0 guibg=#c6c6c6 guifg=#000000 cterm=bold gui=bold
highlight viraDetailsStatusSelected ctermbg=251 ctermfg=0 guibg=#c6c6c6 guifg=#000000 cterm=bold gui=bold
highlight viraDetailsTypeAssignee ctermfg=lightblue guifg=lightblue cterm=bold gui=bold
highlight viraDetailsTypeBug ctermfg=red guifg=red cterm=bold gui=bold
highlight viraDetailsTypeEpic ctermfg=white ctermbg=53 guifg=white guibg=#5b005f  cterm=bold gui=bold
highlight viraDetailsTypeStory ctermfg=lightgreen guifg=lightgreen  cterm=bold gui=bold
highlight viraDetailsTypeTask ctermfg=darkblue guifg=darkblue cterm=bold gui=bold
highlight viraItalic cterm=italic gui=italic
highlight viraLink cterm=underline gui=underline
highlight viraStrikethrough cterm=strikethrough gui=strikethrough
highlight viraUnderline cterm=underline gui=underline
" }}}

let b:current_syntax = vira#_get_version()
