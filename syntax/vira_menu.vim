" Quit when a syntax file was already loaded.
if exists('b:current_syntax') | finish | endif

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
syntax match viraIssuesIssue ".*-.* │.*│.*│.*│.*" contains=viraIssuesDescription
syntax match viraIssuesDescription "│.*"hs=s+2 nextgroup=viraIssuesStatus contains=viraIssuesStatus, contained
syntax match viraIssuesStatus "  │.*" contains=viraIssuesDates,viraDetailsTypeBug,viraDetailsTypeEpic,viraDetailsTypeStory,viraDetailsTypeTask,viraDetailsStatusInProgress,viraDetailsStatusTodo,viraDetailsStatusSelected,viraDetailsStatusDone,viraDetailsStatusComplete,viraDetailsStatusBacklog,viraIssuesStatus nextgroup=viraIssuesStatus contained
syntax match viraDetailsStatusInProgress "In Progress │"he=e-2
syntax match viraDetailsStatusBacklog "Backlog │"he=e-2
syntax match viraDetailsStatusComplete "Complete │"he=e-2
syntax match viraDetailsStatusDone "Done │"he=e-2
syntax match viraDetailsStatusSelected "Selected for Development │"he=e-2
syntax match viraDetailsStatusTodo "To Do │"he=e-2
syntax match viraDetailsTypeBug "Bug │"he=e-2
syntax match viraDetailsTypeEpic "Epic │"he=e-2
syntax match viraDetailsTypeStory "Story │"he=e-2
syntax match viraDetailsTypeTask "Task │"he=e-2
highlight default link viraIssuesIssue Question
highlight default link viraIssuesDescription Statement
highlight default link viraIssuesStatus NonText

" Servers {{{2
syntax match viraHTML "https://.*"
highlight default link viraHTML Question

" Style {{{2
syntax match viraBold "\*.*\*"
syntax match viraBullets ".*\* "
syntax match viraCitvtion "??.*??"

highlight viraBold cterm=bold gui=bold
highlight default link viraBullets Identifier
highlight default link viraCitvtion Title

" Report {{{2
" Details {{{3
syntax match viraCommentAuthor /.*@/hs=s,he=e contains=viraCommentDate nextgroup=viraCommentDate
syntax region viraCommentClose start="}}" end="}"
syntax match viraCommentDate /@.*/hs=s,he=e contained

syntax match viraDetails "┌.*"
syntax match viraDetails "│"

syntax match viraDetailsA "│.*│.*│"he=e-1 contains=viraDetailsB,viraDetailsC,viraDetailsD nextgroup=viraDetailsB
syntax match viraDetailsB "│.*│"hs=s,he=e-1 nextgroup=viraDetailsC
syntax match viraDetailsC "│.*"hs=s,he=e-1
syntax match viraDetailsE "│.*│.*"hs=e,he=e
syntax match viraDetails "│"

syntax match viraDetails "│.*Created.* │" contains=viraDetailsDates
syntax match viraDetails "│.*Updated.* │" contains=viraDetailsDates
syntax match viraDetailsDates "│ .*.-.*.-.* │"hs=s+17,he=e-2 contained

syntax match viraDetails "│.*Type │"
syntax match viraDetailsTypeBug "Bug  "he=e-2
syntax match viraDetailsTypeEpic "Epic  "he=e-2
syntax match viraDetailsTypeStory "Story  "he=e-2
syntax match viraDetailsTypeTask "Task  "he=e-2

syntax match viraDetails "│.*Status │"
syntax match viraDetailsStatusComplete "Complete   "he=e-3
syntax match viraDetailsStatusDone "Done   "he=e-3
syntax match viraDetailsStatusInProgress "In Progress   "he=e-3
syntax match viraDetailsStatusTodo "To Do   "he=e-3
syntax match viraDetailsStatusBacklog "Backlog   "he=e-3
" TODO: VIRA-177 [200612] - "Selected for Development" can be the longest string re: style
syntax match viraDetailsStatusSelected "Selected for Development "he=e-1

syntax match viraDetails "│.*Story Points │"

syntax match viraDetails "│.*Priority │"
syntax match viraDetailsHigh "High  "he=s+4
syntax match viraDetailsHighest "Highest  "he=s+7
syntax match viraDetailsLow "Low  "he=s+3
syntax match viraDetailsLowest "Lowest  "he=s+6
syntax match viraDetailsMedium "Medium  "he=s+6

syntax match viraDetails "│.*Component │"
syntax match viraDetails "│.*Version │"

syntax match viraDetails "│.*Assignee │" nextgroup=viraDetailsTypeAssignee
syntax match viraDetailsTypeAssignee ".*  "hs=s+1,he=e-2 contained

syntax match viraDetails "│.*Reporter │" nextgroup=viraDetailsTypeReporter
syntax match viraDetailsTypeReporter ".*  "hs=s+1,he=e-2 contained

syntax match viraDetails "├.*"
syntax match viraDetails "└.*"

" Comments {{{3
syntax match viraItalic "_.*_"
syntax match viraLink "\[.*|.*\]"
syntax match viraMonospaced "{{.*}}"
syntax match viraPhoto "\!.*|.*\!"
syntax match viraStory "\v.*" contained
syntax match viraStrikethrough "-.*-"
syntax match viraSubscript "\~.*\~"
syntax match viraTheLine "----"
syntax match viraTitles "  .*-.*  \|Summary\|Description\|Comments\n"hs=s,he=e
syntax match viraTitle "\%1l.*:" contained nextgroup=viraStory
syntax match viraTitleComment /.*{{1/hs=s,he=e contains=viraTitleFold nextgroup=viraTitleFold
syntax match viraTitleFold /{{.*/hs=s,he=e contained
syntax match viraUnderline "+.*+"
syntax match viraUsername "\[\~.*\]"
syntax region viraCode start=/{code.*}/ end=/{code}/
syntax region viraNoformat start=/{noformat.*}/ end=/{noformat}/

" Highlighting {{{1
highlight default link viraCode Question
highlight default link viraCommentClose Statement
highlight default link viraCommentDate Statement
highlight default link viraDetailsA Identifier
highlight default link viraDetailsB Identifier
highlight default link viraDetailsC Identifier
highlight default link viraDetailsD Normal
highlight default link viraDetailsE Identifier
highlight default link viraDetailsF Identifier
highlight default link viraDetails Identifier
highlight default link viraMonospaced Question
highlight default link viraNoformat Normal
highlight default link viraPhoto Title
highlight default link viraStory Identifier
highlight default link viraSubscript Question
highlight default link viraTheLine Title
highlight default link viraTitles Title
highlight default link viraTitle Title
highlight default link viraTitleComment Question
highlight default link viraTitleDescription Question
highlight default link viraTitleFold Statement
highlight default link viraDetailsTypeAssignee Statement
highlight default link viraDetailsTypeReporter Statement
highlight default link viraDetailsDates Statement

highlight viraDetailsDates ctermfg=yellow guifg=yellow
highlight viraDetailsHigh ctermfg=red guifg=red
highlight viraDetailsHighest ctermfg=darkred guifg=darkred
highlight viraDetailsLow ctermfg=darkgreen guifg=darkgreen
highlight viraDetailsLowest ctermfg=green guifg=green
highlight viraDetailsMedium ctermfg=darkyellow guifg=darkyellow
highlight viraDetailsStatusComplete ctermbg=darkgreen ctermfg=white guibg=darkgreen guifg=white cterm=bold gui=bold
highlight viraDetailsStatusDone ctermbg=darkgreen ctermfg=white guibg=darkgreen guifg=white cterm=bold gui=bold
highlight viraDetailsStatusInProgress ctermbg=darkblue ctermfg=white guibg=darkblue guifg=white cterm=bold gui=bold
highlight viraDetailsStatusTodo ctermbg=grey ctermfg=black guibg=grey guifg=black cterm=bold gui=bold
highlight viraDetailsStatusBacklog ctermbg=grey ctermfg=black guibg=grey guifg=black cterm=bold gui=bold
highlight viraDetailsStatusSelected ctermbg=grey ctermfg=black guibg=grey guifg=black cterm=bold gui=bold
highlight viraDetailsTypeBug ctermfg=red guifg=red cterm=bold gui=bold
highlight viraDetailsTypeEpic ctermfg=white ctermbg=53 guifg=white guibg=#5b005f  cterm=bold gui=bold
highlight viraDetailsTypeStory ctermfg=lightgreen guifg=lightgreen  cterm=bold gui=bold
highlight viraDetailsTypeTask ctermfg=darkblue guifg=darkblue cterm=bold gui=bold
highlight viraItalic cterm=italic gui=italic
highlight viraLink cterm=underline gui=underline
highlight viraStrikethrough cterm=strikethrough gui=strikethrough
highlight viraUnderline cterm=underline gui=underline
highlight viraUsername cterm=underline gui=underline

let b:current_syntax = 'vira_menu'
