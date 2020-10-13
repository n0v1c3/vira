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
syntax region viraCommentOlder start=/^\d.* Older Comment.* {/ end=/{{\d/
syntax match viraCommentAuthor /^\w.*\s@\s\d\{4\}.*/hs=s,he=e contains=viraCommentDate
syntax match viraCommentDate / @ .* {/hs=s,he=e-1 contained contains=viraCommentOpen,viraCommentDateAt
syntax match viraCommentDateAt /@/hs=s,he=e contained
syntax match viraCommentOpen /.*{{{.*/hs=e-4 contained
syntax match viraCommentClose "}}}"

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

syntax match viraDetails "│.*Epic Link │" nextgroup=viraDetailsEpic
syntax match viraDetailsEpic ".*-.*\d \| None "hs=s+1,he=e-1 contained

syntax match viraDetails "├.*"
syntax match viraDetails "└.*"

" Font Style {{{2
syntax match viraItalic " _.*_ "hs=s+1,he=e-1
syntax match viraLink " \[.*|.*\] "hs=s+1,he=e-1
syntax match viraMonospaced " {{.*}} "hs=s+1,he=e-1
syntax match viraPhoto " \!.*|.*\! "hs=s+1,he=e-1
syntax match viraStory "\v.*" contained
syntax match viraStrikethrough " -.*- "hs=s+1,he=e-1
syntax match viraSubscript " \~.*\~ "hs=s+1,he=e-1
syntax match viraTheLine "----"
syntax match viraTitles "  .*-.*  \|│.*Summary.*│\|│.*Description.*│\|│.*Comments.*│"hs=s+1,he=e-1 contains=viraDetails
syntax match viraTitle "\%1l.*:" contained nextgroup=viraStory
syntax match viraUnderline "+.*+"
syntax region viraNoformat start=/{noformat.*}/ end=/{noformat}/
syntax match viraList "\[ ]\|\[X]\|\[x]\|\[✓]" contains=viraListCheck
syntax match viraListCheck "\[X]\|\[x]\|\[✓]"hs=s+1,he=e-1 contained
syntax match viraPointer "└──>"
syntax match viraUsername "\[\~.*\]"

" Code Wrap {{{2
" OoO is very important
syntax match viraCodeNumber "\d" contained
syntax match viraCodeNumber "\d.\d" contained
syntax match viraCodeComment "//.*\|#.*\|\".*\n" contained
syntax match viraCodeSemi "\~\|;\|(\|\[\|]\|)\|=\|:\|,\|\." contained
syntax region viraCodeQuote start="\(^\|=\|\s\|\[\|\,\|\-\)'"hs=s+1 end="'" skip="\\'"
syntax region viraCodeQuote start="\(^\|=\|\s\|\[\|\,\|\-\)\""hs=s+1 end="\"" skip="\\\""
syntax region viraCodeQuote start="'" end="'" skip="\\'" contained
syntax region viraCodeQuote start="\"" end="\"" skip="\\\"" contained
syntax match viraCodeFunction " \w.*\w(" contained contains=viraCodeSemiFix
syntax match viraCodeMethod "ASC\|DESC\|desc\|\~\|ORDER \|order \|BY \|by \|or \|OR \|and\|AND\|in\|return\|==\|!=\|<\|>\|def\|for\|in\|true\|True\|false\|False" contained
syntax match viraCodeFunction "syntax\|string\|int\|echo\|print\|self" contained
syntax match viraCodeSemiFix "\.\|(\|\[\|=" contained
syntax region viraCodeQuote start="\"" end="\"" skip="\\\"" contained
syntax region viraCode start=/{code:.*}/ end=/{code}/ contains=viraCodeFunction,viraCodeQuote,viraCodeSemi,viraCodeComment,viraCodeVariable,viraCodeMethod,viraCodeNumber,viraCodeSemiFix
syntax match viraCode "{code:.*}.*{code}" contains=viraCodeFunction,viraCodeQuote,viraCodeSemi,viraCodeComment,viraCodeVariable,viraCodeMethod,viraCodeNumber,viraCodeSemiFix

" Highlighting {{{1
highlight default link viraBullets Identifier
highlight default link viraCitvtion Title
highlight default link viraDetails Identifier
highlight default link viraDetailsA Identifier
highlight default link viraDetailsB Identifier
highlight default link viraDetailsC Identifier
highlight default link viraDetailsD Normal
highlight default link viraDetailsDates Statement
highlight default link viraDetailsE Identifier
highlight default link viraDetailsF Identifier
highlight default link viraHTML Title
highlight default link viraIssuesDescription Question
highlight default link viraIssuesIssue Title
highlight default link viraIssuesStatus Statement
highlight default link viraMonospaced Question
highlight default link viraNoformat Normal
highlight default link viraPhoto Title
highlight default link viraStory Identifier
highlight default link viraSubscript Question
highlight default link viraTheLine Title
highlight default link viraTitle Title
highlight default link viraTitleComment Question
highlight default link viraTitleDescription Question
highlight default link viraTitleFold Statement
highlight default link viraTitles Title
highlight viraBold cterm=bold gui=bold
highlight viraCode ctermfg=5 guifg=#875f5f
highlight viraCodeComment ctermfg=245 guifg=#87af00
highlight viraCodeFunction ctermfg=26 guifg=#00afd7 cterm=bold gui=bold
highlight viraCodeQuote ctermfg=76 guifg=#5fd700
highlight viraCodeSemiFix ctermfg=245 guifg=#87af00
highlight viraCodeSemi ctermfg=245 guifg=#87af00
highlight viraCodeMethod ctermfg=3 guifg=#808000
highlight viraCodeNumber ctermfg=39 guifg=#808000
highlight viraCommentAuthor ctermfg=lightblue guifg=lightblue cterm=bold,underline gui=bold,underline
highlight viraCommentClose ctermbg=bg ctermfg=bg guibg=bg guifg=bg
highlight viraCommentDate ctermfg=darkblue guifg=darkblue cterm=underline, gui=underline
highlight viraCommentDateAt ctermfg=blue guifg=blue cterm=underline, gui=underline
highlight viraCommentOlder ctermbg=bg ctermfg=bg guifg=bg guibg=bg cterm=bold gui=bold
highlight viraCommentOpen ctermbg=bg ctermfg=bg guibg=bg guifg=bg
highlight viraDetailsComponent ctermfg=lightblue guifg=lightblue
highlight viraDetailsDates ctermfg=darkblue guifg=darkblue
highlight viraDetailsHigh ctermfg=red guifg=red
highlight viraDetailsHighest ctermfg=darkred guifg=darkred
highlight viraDetailsLow ctermfg=darkgreen guifg=darkgreen
highlight viraDetailsLowest ctermfg=green guifg=green
highlight viraDetailsMedium ctermfg=darkyellow guifg=darkyellow
highlight viraDetailsStatusBacklog ctermbg=darkgrey ctermfg=white guibg=darkgrey guifg=white
highlight viraDetailsStatusComplete ctermbg=darkgreen ctermfg=white guibg=darkgreen guifg=white
highlight viraDetailsStatusDone ctermbg=darkgreen ctermfg=white guibg=darkgreen guifg=white
highlight viraDetailsStatusInProgress ctermbg=darkblue ctermfg=white guibg=darkblue guifg=white
highlight viraDetailsStatusSelected ctermbg=grey ctermfg=black guibg=grey guifg=black
highlight viraDetailsStatusTodo ctermbg=grey ctermfg=black guibg=grey guifg=black
highlight viraDetailsStoryPoints ctermfg=darkyellow guifg=lightblue
highlight viraDetailsTypeAssignee ctermfg=lightblue guifg=lightblue cterm=bold gui=bold
highlight viraDetailsTypeBug ctermfg=red guifg=red
highlight viraDetailsTypeEpic ctermfg=white ctermbg=53 guifg=white guibg=#5b005f
highlight viraDetailsEpic ctermfg=white ctermbg=53 guifg=white guibg=#5b005f
highlight viraDetailsTypeReporter ctermfg=lightblue guifg=lightblue cterm=bold gui=bold
highlight viraDetailsTypeStory ctermfg=lightgreen guifg=lightgreen
highlight viraDetailsTypeTask ctermfg=darkblue guifg=darkblue
highlight viraDetailsVersion ctermfg=darkblue guifg=darkblue
highlight viraDetailsVersionN ctermfg=lightblue guifg=lightblue
highlight viraDetailsVersionP ctermfg=darkyellow guifg=darkyellow
highlight viraItalic cterm=italic gui=italic
highlight viraLink cterm=underline gui=underline
highlight viraList ctermfg=brown guifg=brown
highlight viraListCheck ctermfg=lightgreen guifg=lightgreen
highlight viraPointer ctermfg=darkblue guifg=darkblue
highlight viraStrikethrough cterm=strikethrough gui=strikethrough
highlight viraUnderline cterm=underline gui=underline
highlight viraUsername ctermfg=lightblue guifg=lightblue cterm=underline gui=underline

let b:current_syntax = 'vira_report'
