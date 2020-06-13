" Quit when a syntax file was already loaded.
if exists('b:current_syntax') | finish|  endif

" Syntax matching {{{1
syntax match viraHTML "https://.*"hs=s,he=e
syntax match viraIssuesDescription "\~  .*"hs=s+3 contains=viraIssuesStatus nextgroup=viraIssuesStatus
syntax match viraIssuesStatus "| .* -> .*" contains=viraIssuesAssignee,viraDetailsTypeBug,viraDetailsTypeEpic,viraDetailsTypeStory,viraDetailsTypeTask,viraDetailsStatusInProgress,viraDetailsStatusTodo,viraDetailsStatusSelected,viraDetailsStatusDone,viraDetailsStatusComplete,viraDetailsStatusBacklog,viraIssuesStatus nextgroup=viraIssuesStatus
syntax match viraDetailsStatusInProgress "In Progress  ->"he=e-4
syntax match viraDetailsStatusBacklog "Backlog  ->"he=e-3
syntax match viraDetailsStatusComplete "Complete  ->"he=e-3
syntax match viraDetailsStatusDone "Done  ->"he=e-3
syntax match viraDetailsStatusSelected "Selected for Development  ->"he=e-3
syntax match viraDetailsStatusTodo "To Do  ->"he=e-3
syntax match viraDetailsTypeBug "|  Bug"hs=s+3
syntax match viraDetailsTypeEpic "|  Epic"hs=s+3
syntax match viraDetailsTypeStory "|  Story"hs=s+3
syntax match viraDetailsTypeTask "|  Task"hs=s+3
syntax match viraIssuesAssignee "  ->  "
" syntax match viraIssuesStatus "| .* |" contained

syntax match viraIssuesIssue ".*-.*  \~"he=e contains=viraIssuesDescription nextgroup=viraIssuesDescription
syntax match viraBold "\*.*\*"
syntax match viraBullets ".*\* "
syntax match viraCitvtion "??.*??"
syntax match viraCommentAuthor /.*@/hs=s,he=e contains=viraCommentDate nextgroup=viraCommentDate
syntax match viraCommentClose "}}}"
syntax match viraCommentDate /@.*/hs=s,he=e contained

" Report {{{2
syntax match viraDetails "┌.*"
syntax match viraDetails "│"

syntax match viraDetailsA "│.*│.*│"he=e-1 contains=viraDetailsB,viraDetailsC,viraDetailsD nextgroup=viraDetailsB
syntax match viraDetailsB "│.*│"hs=s,he=e-1 nextgroup=viraDetailsC
syntax match viraDetailsC "│.*"hs=s,he=e-1
syntax match viraDetailsE "│.*│.*"hs=e,he=e
syntax match viraDetails "│"

syntax match viraDetails "│.*Created │"
syntax match viraDetails "│.*Updated │"

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
syntax match viraDetailsHigh "High  "hs=s+16
syntax match viraDetailsHighest "Highest  "hs=s+16
syntax match viraDetailsLow "Low  "hs=s+16
syntax match viraDetailsLowest "Lowest  "hs=s+16
syntax match viraDetailsMedium "Medium  "he=s+6

syntax match viraDetails "│.*Component │"
syntax match viraDetails "│.*Version │"

syntax match viraDetails "│.*Assignee │" nextgroup=viraDetailsTypeAssignee
syntax match viraDetailsTypeAssignee ".*  "hs=s+1,he=e-2 contained

syntax match viraDetails "│.*Reporter │" nextgroup=viraDetailsTypeReporter
syntax match viraDetailsTypeReporter ".*  "hs=s+1,he=e-2 contained

syntax match viraDetails "├.*"
syntax match viraDetails "└.*"

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

" Highlighting
highlight default link viraHTML Title
highlight default link viraIssuesStatus Statement
highlight default link viraIssuesDescription Question
highlight default link viraIssuesIssue Title
highlight default link viraBullets Identifier
highlight default link viraCitvtion Title
highlight default link viraCode Question
highlight default link viraCommentAuthor Identifier
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
highlight default link viraIssuesAssignee Statement
highlight viraBold cterm=bold gui=bold
highlight viraDetailsHigh ctermfg=red guifg=red
highlight viraDetailsHighest ctermfg=darkred guifg=darkred
highlight viraDetailsLow ctermfg=darkgreen guifg=darkgreen
highlight viraDetailsLowest ctermfg=green guifg=green
highlight viraDetailsMedium ctermfg=darkyellow guifg=darkyellow
highlight viraDetailsStatusComplete ctermbg=darkgreen ctermfg=white guibg=darkgreen guifg=white
highlight viraDetailsStatusDone ctermbg=darkgreen ctermfg=white guibg=darkgreen guifg=white
highlight viraDetailsStatusInProgress ctermbg=darkyellow ctermfg=black guibg=darkyellow guifg=black
highlight viraDetailsStatusTodo ctermbg=darkgrey ctermfg=white guibg=darkgrey guifg=white
highlight viraDetailsStatusBacklog ctermbg=darkgrey ctermfg=white guibg=darkgrey guifg=white
highlight viraDetailsStatusSelected ctermbg=darkyellow ctermfg=black guibg=darkyellow guifg=black
highlight viraDetailsTypeBug ctermfg=red guifg=red
highlight viraDetailsTypeEpic ctermfg=white ctermbg=53 guifg=white guibg=#5b005f
highlight viraDetailsTypeStory ctermfg=lightgreen guifg=lightgreen
highlight viraDetailsTypeTask ctermfg=darkblue guifg=darkblue
highlight viraItalic cterm=italic gui=italic
highlight viraLink cterm=underline gui=underline
highlight viraStrikethrough cterm=strikethrough gui=strikethrough
highlight viraUnderline cterm=underline gui=underline
highlight viraUsername cterm=underline gui=underline

let b:current_syntax = 'vira'
