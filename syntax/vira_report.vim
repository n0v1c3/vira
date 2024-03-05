" Quit when a syntax file was already loaded.
if exists('b:vira_version') && b:vira_version == vira#_get_version() | finish | endif

" Syntax matching {{{1
syntax match viraHTML "https://.*"hs=s,he=e
syntax match viraIssuesIssue ".*-.* │.*│.*│.*│.*" contains=viraIssuesDescription
syntax match viraIssuesDescription "│.*"hs=s+2 nextgroup=viraIssuesStatus contains=viraIssuesStatus,viraGV,viraGVBar contained
syntax match viraIssuesStatus "  │.*" contains=viraIssuesDates,viraDetailsTypeBug,viraDetailsTypeEpic,viraDetailsTypeStory,viraDetailsTypeTask,viraDetailsStatusInProgress,viraDetailsStatusTodo,viraDetailsStatusSelected,viraDetailsStatusDone,viraDetailsStatusComplete,viraDetailsStatusBacklog,viraIssuesStatus nextgroup=viraIssuesStatus contained

highlight viraDescription ctermfg=108 guifg=#87af87

syntax match viraVira "\cJIRA"
syntax match viraBold "\*.*\*"
syntax match viraBullets ".*\* "
syntax match viraCitvtion "??.*??"
syntax region viraCommentOlder start=/^\d.* Older Comment.* {/ end=/{{\d/
syntax match viraCommentAuthor /^\w.*\s@\s\d\{4\}.*/hs=s,he=e contains=viraCommentDate
syntax match viraCommentDate / @ .* {/hs=s,he=e-1 contained contains=viraCommentOpen,viraCommentDateAt
syntax match viraCommentOpen /.*{{{.*/hs=e-4 contained
" syntax match viraCommentClose "}}}"
syntax region viraCommentClose start="^}}" end="}$"

" syntax match viraCodeBrands '^\cVIRA\s\|^\cVIM\s\|^\cGIT\s\|^\cNEOVIM\s\|^\cNVIM\s\|^\cJIRA\s\|^\cGITHUB\s'he=e-1
" syntax match viraCodeBrands '\s\cVIRA\s\|\s\cVIM\s\|\s\cGIT\s\|\s\cNEOVIM\s\|\s\cNVIM\s\|\s\cJIRA\s\|\s\cGITHUB\s'he=e-1
" syntax match viraCodeBrands '\s\cVIRA\.\|\s\cVIM\.\|\s\cGIT\.\|\s\cNEOVIM\.\|\s\cNVIM\.\|\s\cJIRA\.\|\s\cGITHUB\.'he=e-1
" Report {{{2

syntax match viraDetails "┌.*"
syntax match viraDetails "│"

" syntax match viraDetailsA "│.*│.*│"he=e-1 contains=viraDetailsB,viraDetailsC,viraDetailsD nextgroup=viraDetailsB
" syntax match viraDetailsB "│.*│"hs=s,he=e-1 nextgroup=viraDetailsC
" syntax match viraDetailsC "│.*"hs=s,he=e-1
" syntax match viraDetailsE "│.*│.*"hs=e,he=e
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

syntax match viraDetails "│.*Component(s) │.*" contains=viraDetailsComponent
syntax match viraDetailsComponent " │.*│"hs=s+3,he=e-1 contained

syntax match viraDetails "│.*Version(s) │" contains=viraDetailsVersionN,viraDetailsVersionP,viraDetailsVersion
syntax match viraDetailsVersionN " │ .* "hs=s+3,he=e-1 contained contains=viraDetailsVersionP
syntax match viraDetailsVersionN " │ .* .*,.* "hs=s+3,he=e-1 contained contains=viraDetailsVersionP
" syntax match viraDetailsVersionP " | .*%"hs=s+2 contained contains=viraDetailsVersion
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
syntax match viraList "\[ ]\|\[X]\|\[x]\|\[✓]\|\[-]\|\[>]" contains=viraListComplete,viraListRemoved,viraListForward
syntax match viraListComplete "\[X]\|\[x]\|\[✓]"hs=s+1,he=e-1 contained
syntax match viraListRemoved "\[-]"hs=s+1,he=e-1 contained
syntax match viraListForward "\[>]"hs=s+1,he=e-1 contained
syntax match viraPointer "└──>"
syntax match viraUsername "\[\~.*\]\|@\w\+"

" Code Wrap {{{2
" Order of operations is very important
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
syntax region viraCode start="^`" end="`."he=e-1 skip="\\\""
syntax region viraCode start=" `" end="`."he=e-1 skip="\\\""
syntax region viraCode start=" `" end="\n\|`" skip="\\\""
syntax region viraCode start="^`" end="\n\|`" skip="\\\""
syntax region viraCode start="(`"hs=s+1 end="`)"he=e-1 skip="\\\""
syntax region viraCode start=/$\n```/ end=/```\n\n\|}}/ contains=viraCodeFunction,viraCodeQuote,viraCodeSemi,viraCodeComment,viraCodeVariable,viraCodeMethod,viraCodeNumber,viraCodeSemiFix
syntax region viraCode start=/{code:.*}/ end=/{code}/ contains=viraCodeFunction,viraCodeQuote,viraCodeSemi,viraCodeComment,viraCodeVariable,viraCodeMethod,viraCodeNumber,viraCodeSemiFix
syntax match viraCode "{code:.*}.*{code}" contains=viraCodeFunction,viraCodeQuote,viraCodeSemi,viraCodeComment,viraCodeVariable,viraCodeMethod,viraCodeNumber,viraCodeSemiFix
" Plugin Support {{{3
syntax region viraCode start=/^{code:.*}\n```GV```/ end=/{code}/ contains=viraGV,viraGVBar
syntax region viraCode start=/^{code:.*}\n```git```/ end=/{code}/ contains=viraGV,viraGVBar
syntax region viraCode start=/^{code:.*}\n```glog```/ end=/{code}/ contains=viraGV,viraGVBar
syntax region viraCode start=/^{code:.*}\n```git-log```/ end=/{code}/ contains=viraGV,viraGVBar
syntax region viraCode start=/^{code:.*}\n```git-vira```/ end=/{code}/ contains=viraGV,viraGVBar
" }}}
" Common Tags {{{2
syntax match viraTodos "FYI\|TODOs\|TODO"

" Highlighting {{{1
highlight default link viraBullets Identifier
highlight default link viraCitvtion Title
highlight default link viraDetails Identifier
" highlight default link viraDetailsA Identifier
" highlight default link viraDetailsB Identifier
" highlight default link viraDetailsC Identifier
" highlight default link viraDetailsD Normal
highlight default link viraDetailsDates Statement
highlight default link viraDetailsE Identifier
highlight default link viraDetailsF Identifier
highlight default link viraHTML Title
" highlight default link viraIssuesDescription Question
" highlight viraIssuesIssue ctermfg=226 guifg=#ffd7af
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
syntax match viraTitleFold /{{.*/hs=s,he=e contained
highlight default link viraTitleFold Statement
highlight viraTitles ctermfg=186 guifg=#d7d785 cterm=bold gui=bold
highlight viraBold cterm=bold gui=bold
highlight viraCode ctermfg=3 guifg=#808000
highlight viraCodeComment ctermfg=245 guifg=#87af00
highlight viraCodeFunction ctermfg=26 guifg=#00afd7 cterm=bold gui=bold
highlight viraCodeQuote ctermfg=76 guifg=#5fd700
highlight viraCodeSemiFix ctermfg=245 guifg=#87af00
highlight viraCodeSemi ctermfg=245 guifg=#87af00
highlight viraCodeMethod ctermfg=3 guifg=#808000
highlight viraCodeNumber ctermfg=39 guifg=#808000
highlight viraCommentAuthor ctermfg=lightgreen guifg=lightblue cterm=bold,underline gui=bold,underline
highlight viraCommentClose ctermbg=bg ctermfg=bg guibg=bg guifg=bg
highlight viraCommentDate ctermfg=green guifg=green cterm=underline gui=underline
highlight viraCommentDateAt ctermfg=blue guifg=blue cterm=underline gui=underline
highlight viraCommentOlder ctermbg=bg ctermfg=bg guifg=bg guibg=bg cterm=bold gui=bold
highlight viraCommentOpen ctermbg=bg ctermfg=bg guibg=bg guifg=bg
highlight viraDetailsComponent ctermfg=lightblue guifg=lightblue
highlight viraDetailsDates ctermfg=green guifg=green
highlight viraDetailsHigh ctermfg=red guifg=red
highlight viraDetailsHighest ctermfg=darkred guifg=darkred
highlight viraDetailsLow ctermfg=darkgreen guifg=darkgreen
highlight viraDetailsLowest ctermfg=green guifg=green
highlight viraDetailsMedium ctermfg=darkyellow guifg=darkyellow
highlight viraDetailsStatusComplete ctermbg=darkgreen ctermfg=white guibg=darkgreen guifg=white
highlight viraDetailsStatusDone ctermbg=darkgreen ctermfg=white guibg=darkgreen guifg=white
highlight viraDetailsStatusInProgress ctermbg=green ctermfg=white guibg=green guifg=white
highlight viraDetailsStatusTodo ctermbg=251 ctermfg=0 guibg=#c6c6c6 guifg=#000000 cterm=bold gui=bold
highlight viraDetailsStatusBacklog ctermbg=251 ctermfg=0 guibg=#c6c6c6 guifg=#000000 cterm=bold gui=bold
highlight viraDetailsStatusSelected ctermbg=251 ctermfg=0 guibg=#c6c6c6 guifg=#000000 cterm=bold gui=bold
highlight viraDetailsStoryPoints ctermfg=darkyellow guifg=lightblue
highlight viraDetailsTypeAssignee ctermfg=lightblue guifg=lightblue cterm=bold gui=bold
highlight viraDetailsTypeBug ctermfg=red guifg=red
highlight viraDetailsTypeEpic ctermfg=white ctermbg=53 guifg=white guibg=#5b005f
highlight viraDetailsEpic ctermfg=white ctermbg=53 guifg=white guibg=#5b005f
highlight viraDetailsTypeReporter ctermfg=lightblue guifg=lightblue cterm=bold gui=bold
highlight viraDetailsTypeStory ctermfg=lightgreen guifg=lightgreen
highlight viraDetailsTypeTask ctermfg=green guifg=green
highlight viraDetailsVersion ctermfg=green guifg=green
highlight viraDetailsVersionN ctermfg=lightblue guifg=lightblue
highlight viraDetailsVersionP ctermfg=darkyellow guifg=darkyellow
highlight viraItalic cterm=italic gui=italic
highlight viraLink cterm=underline gui=underline
highlight viraList ctermfg=lightblue guifg=lightblue cterm=bold gui=bold
highlight viraListComplete ctermfg=lightgreen guifg=lightgreen cterm=bold gui=bold
highlight viraListForward ctermfg=yellow guifg=yellow cterm=bold gui=bold
highlight viraListRemoved ctermfg=darkred guifg=darkred cterm=bold gui=bold
highlight viraPointer ctermfg=yellow guifg=yellow cterm=bold gui=bold
highlight viraStrikethrough cterm=strikethrough gui=strikethrough
highlight viraTodos cterm=bold,underline gui=bold,underline
highlight viraUnderline cterm=underline gui=underline
highlight viraUsername ctermfg=lightblue guifg=lightblue cterm=underline gui=underline

" GV Style {{{2
syntax match viraGV "^.*\d\{4}-\d\{2}-\d\{2}\s\w\{7}\s.*$" contains=viraGVTag
syntax match viraGVBar "^|.*\*\s\+$\|^|.*\\\s\+$\|^|.*|\s\+$\||.*/\s\+$"
syntax match viraGVBar "^|.*\*$\|^|.*\\$\|^|.*|$\||.*/$"
syntax match viraGVTag "^*.*\||.*" contained contains=viraGVDate
syntax match viraGVDate " \d\{4}-\d\{2}-\d\{2} " contained nextgroup=viraGVHeader
syntax match viraGVHeader "\w\{7}\s" contained nextgroup=viraGVMessage contains=viraGVBranch
syntax match viraGVMessage ".*(.*)$" contained contains=viraGVIssue,viraVGBranch,viraGVCode,viraGVUsername
syntax match viraGVIssue "\w\+-\d\+:\s\|\w\+-\d\+\s" contained contains=viraGVIssueUnderline
syntax match viraGVIssue "#\d\+:\s\|#\d\+\s" contained contains=viraGVIssueUnderline
syntax match viraGVIssueUnderline "\w\+-\d\+\|\d\+" contained
syntax region viraGVCode start="`" end="`" contained
syntax match viraGVBranch "\s(.*)\s" contained nextgroup=viraGVMessage
syntax match viraGVUsername "(.*)$" contained
highlight viraGVTag ctermfg=4 ctermbg=bg guifg=4 guibg=bg
highlight viraGVBar ctermfg=4 ctermbg=bg guifg=4 guibg=bg
highlight viraGVHeader ctermfg=2 ctermbg=bg guifg=2 guibg=bg
highlight viraGVDate ctermfg=1 ctermbg=bg guifg=1 guibg=bg
highlight viraGVBranch ctermfg=35 ctermbg=bg guifg=35 guibg=bg cterm=bold gui=bold
highlight viraGVMessage ctermfg=24 ctermbg=bg guifg=3 guibg=bg
highlight viraGVCode ctermfg=3 ctermbg=bg guifg=#808000 guibg=bg cterm=bold gui=bold
highlight viraGVUsername ctermfg=5 ctermbg=bg guifg=5 guibg=bg
highlight viraGVIssue ctermfg=34 ctermbg=bg guifg=34 guibg=bg cterm=bold gui=bold
highlight viraGVIssueUnderline ctermfg=34 ctermbg=bg guifg=34 guibg=bg cterm=bold,underline gui=bold,underline
" }}}

let b:current_syntax = vira#_get_version()
