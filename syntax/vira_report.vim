" Quit when a syntax file was already loaded.
if exists('b:current_syntax') | finish|  endif

" Syntax matching {{{1
syntax match viraHTML "https://.*"hs=s,he=e
syntax match viraIssuesIssue ".*-.* │.*│.*│.*│.*" contains=viraIssuesDescription
syntax match viraIssuesDescription "│.*"hs=s+2 nextgroup=viraIssuesStatus contains=viraIssuesStatus, contained
syntax match viraIssuesStatus "  │.*" contains=viraIssuesDates,viraDetailsTypeBug,viraDetailsTypeEpic,viraDetailsTypeStory,viraDetailsTypeTask,viraDetailsStatusInProgress,viraDetailsStatusTodo,viraDetailsStatusSelected,viraDetailsStatusDone,viraDetailsStatusComplete,viraDetailsStatusBacklog,viraIssuesStatus nextgroup=viraIssuesStatus contained

syntax match viraBold "\*.*\*"
syntax match viraBullets ".*\* "
syntax match viraCitvtion "??.*??"
syntax match viraCommentAuthor /^\w.*\s@\s\d\{4\}/hs=s,he=e contains=viraCommentDate nextgroup=viraCommentDate
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

syntax match viraDetails "│.*Created.* │" contains=viraDetailsDates
syntax match viraDetails "│.*Updated.* │" contains=viraDetailsDates
syntax match viraDetailsDates "│ .*.-.*.-.* "hs=s+17 contained

syntax match viraDetails "│.*Type │" contains=viraDetailsTypeStory,viraDetailsTypeBug,viraDetailsTypeEpic,viraDetailsTypeEpic,viraDetailsTypeTask
syntax match viraDetailsTypeBug "│ Bug"hs=s+2 contained
syntax match viraDetailsTypeEpic "│ Epic"hs=s+2 contained
syntax match viraDetailsTypeStory "│ Story"hs=s+2 contained
syntax match viraDetailsTypeTask "│ Task"hs=s+2 contained

syntax match viraDetails "│.*Status │" contains=viraDetailsStatusBacklog,viraDetailsStatusComplete,viraDetailsStatusDone,viraDetailsStatusInProgress,viraDetailsStatusTodo,viraDetailsStatusSelected
syntax match viraDetailsStatusBacklog "│ Backlog"hs=s+2 contained
syntax match viraDetailsStatusComplete "│ Complete"hs=s+2 contained
syntax match viraDetailsStatusDone "│ Done"hs=s+2 contained
syntax match viraDetailsStatusInProgress "│ In Progress"hs=s+2 contained
syntax match viraDetailsStatusSelected "│ Selected for Development"hs=s+2 contained
syntax match viraDetailsStatusTodo "│ To Do"hs=s+2 contained

syntax match viraDetails "│.*Story Points │.*" contains=viraDetailsStoryPoints
syntax match viraDetailsStoryPoints " │.*│"hs=s+3,he=e-1 contained

syntax match viraDetails "│.*Priority │" contains=viraDetailsHigh,viraDetailsHighest,viraDetailsLowest,viraDetailsLow,viraDetailsMedium
syntax match viraDetailsHigh "│ High"hs=s+2 contained
syntax match viraDetailsHighest "│ Highest"hs=s+2 contained
syntax match viraDetailsLow "│ Low"hs=s+2 contained
syntax match viraDetailsLowest "│ Lowest"hs=s+2 contained
syntax match viraDetailsMedium "│ Medium"hs=s+2 contained

syntax match viraDetails "│.*Component │.*" contains=viraDetailsComponent
syntax match viraDetailsComponent " │.*│"hs=s+3,he=e-1 contained

syntax match viraDetails "│.*Version │" contains=viraDetailsVersionN,viraDetailsVersionP,viraDetailsVersion
syntax match viraDetailsVersionN " │.* .* |"hs=s+3,he=e-1 contained contains=viraDetailsVersionP
syntax match viraDetailsVersionP " | .*%"hs=s+2 contained contains=viraDetailsVersion
syntax match viraDetailsVersion "|" contained

syntax match viraDetails "│.*Assignee │" nextgroup=viraDetailsTypeAssignee
syntax match viraDetailsTypeAssignee ".* .* "hs=s+1 contained

syntax match viraDetails "│.*Reporter │" nextgroup=viraDetailsTypeReporter
syntax match viraDetailsTypeReporter ".* .* "hs=s+1 contained

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
highlight default link viraDetailsDates Statement
" highlight default link viraDetailsVersionP Question
" highlight default link viraDetailsVersionN Title
highlight viraDetailsDates ctermfg=yellow guifg=yellow
highlight viraBold cterm=bold gui=bold
highlight viraDetailsHigh ctermfg=red guifg=red
highlight viraDetailsHighest ctermfg=darkred guifg=darkred
highlight viraDetailsLow ctermfg=darkgreen guifg=darkgreen
highlight viraDetailsLowest ctermfg=green guifg=green
highlight viraDetailsMedium ctermfg=darkyellow guifg=darkyellow
highlight viraDetailsStatusComplete ctermbg=darkgreen ctermfg=white guibg=darkgreen guifg=white
highlight viraDetailsStatusDone ctermbg=darkgreen ctermfg=white guibg=darkgreen guifg=white
highlight viraDetailsStatusInProgress ctermbg=darkblue ctermfg=white guibg=darkblue guifg=white
highlight viraDetailsStatusTodo ctermbg=grey ctermfg=black guibg=grey guifg=black
highlight viraDetailsStatusBacklog ctermbg=darkgrey ctermfg=white guibg=darkgrey guifg=white
highlight viraDetailsStatusSelected ctermbg=grey ctermfg=black guibg=grey guifg=black
highlight viraDetailsTypeBug ctermfg=red guifg=red
highlight viraDetailsTypeEpic ctermfg=white ctermbg=53 guifg=white guibg=#5b005f
highlight viraDetailsTypeStory ctermfg=lightgreen guifg=lightgreen
highlight viraDetailsTypeTask ctermfg=darkblue guifg=darkblue
highlight viraDetailsStoryPoints ctermfg=darkyellow guifg=lightblue
highlight viraDetailsComponent ctermfg=lightblue guifg=lightblue
highlight viraDetailsVersion ctermfg=darkblue guifg=darkblue
highlight viraDetailsVersionP ctermfg=darkyellow guifg=darkblue
highlight viraDetailsVersionN ctermfg=lightblue guifg=darkblue
highlight viraItalic cterm=italic gui=italic
highlight viraLink cterm=underline gui=underline
highlight viraStrikethrough cterm=strikethrough gui=strikethrough
highlight viraUnderline cterm=underline gui=underline
highlight viraUsername ctermfg=lightblue guifg=blue cterm=underline gui=underline

let b:current_syntax = 'vira_report'
