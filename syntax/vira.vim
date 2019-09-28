" Quit when a syntax file was already loaded.
if exists('b:current_syntax') | finish|  endif

" Syntax matching
syntax match viraBold "\*.*\*"
syntax match viraBullets ".*\* "
syntax match viraCitvtion "??.*??"
syntax match viraCommentAuthor /.*@/hs=s,he=e contains=viraCommentDate nextgroup=viraCommentDate
syntax match viraCommentClose "}}}"
syntax match viraCommentDate /@.*/hs=s,he=e contained
syntax match viraDetailsA ".*  :"he=e-1 contains=viraDetailsB,viraDetailsC,viraDetailsHighest,viraDetailsHigh,viraDetailsMedium,viraDetailsLow,viraDetailsLowest,viraDetailsStatusTodo,viraDetailsStatusInProgress,viraDetailsStatusComplete,viraDetailsTypeBug,viraDetailsTypeTask,viraDetailsTypeStory,viraDetailsTypeEpic nextgroup=viraDetailsB
syntax match viraDetailsB ":" contained nextgroup=viraDetailsC
syntax match viraDetailsC ":  .*"hs=s+1 contained nextgroup=viraDetailsHigh
syntax match viraDetailsHigh ":  High"hs=s+1 contained nextgroup=viraDetailsHighest
syntax match viraDetailsHighest ":  Highest"hs=s+1 contained nextgroup=viraDetailsLow
syntax match viraDetailsLow ":  Low"hs=s+1 contained nextgroup=viraDetailsLowest
syntax match viraDetailsLowest ":  Lowest"hs=s+1 contained nextgroup=viraDetailsMedium
syntax match viraDetailsMedium ":  Medium"hs=s+1 contained nextgroup=viraDetailsStatusComplete
syntax match viraDetailsStatusComplete ":  Complete"hs=s+3 contained nextgroup=viraDetailsTypeInProgress
syntax match viraDetailsStatusInProgress ":  In Progress"hs=s+3 contained nextgroup=viraDetailsStatusTodo
syntax match viraDetailsStatusTodo ":  To Do"hs=s+3 contained nextgroup=viraDetailsTypeBug
syntax match viraDetailsTypeBug ":  Bug"hs=s+1 contained nextgroup=viraDetailsTypeEpic
syntax match viraDetailsTypeEpic ":  Epic"hs=s+1 contained nextgroup=viraDetailsTypeStory
syntax match viraDetailsTypeStory ":  Story"hs=s+1 contained nextgroup=viraDetailsTypeTask
syntax match viraDetailsTypeTask ":  Task"hs=s+1 contained
syntax match viraItalic "_.*_"
syntax match viraLink "\[.*|.*\]"
syntax match viraMonospaced "{{.*}}"
syntax match viraPhoto "\!.*|.*\!"
syntax match viraStory "\v.*" contained
syntax match viraStrikethrough "-.*-"
syntax match viraSubscript "\~.*\~"
syntax match viraTheLine "----"
syntax match viraTitle "\%1l.*:" nextgroup=viraStory
syntax match viraTitleComment /.*{{1/hs=s,he=e contains=viraTitleFold nextgroup=viraTitleFold
syntax match viraTitleFold /{{.*/hs=s,he=e contained
syntax match viraUnderline "+.*+"
syntax match viraUsername "\[\~.*\]"
syntax region viraCode start=/{code.*}/ end=/{code}/
syntax region viraNoformat start=/{noformat.*}/ end=/{noformat}/

" Highlighting
highlight default link viraBullets Identifier
highlight default link viraCitvtion Title
highlight default link viraCode Question
highlight default link viraCommentAuthor Identifier
highlight default link viraCommentClose Statement
highlight default link viraCommentDate Statement
highlight default link viraDetailsA Identifier
highlight default link viraDetailsB Question
highlight default link viraDetailsC Question
highlight default link viraMonospaced Question
highlight default link viraNoformat Normal
highlight default link viraPhoto Title
highlight default link viraStory Identifier
highlight default link viraSubscript Question
highlight default link viraTheLine Title
highlight default link viraTitle Title
highlight default link viraTitleComment Title
highlight default link viraTitleDescription Title
highlight default link viraTitleFold Statement
highlight viraBold cterm=bold gui=bold
highlight viraDetailsHigh ctermfg=red guifg=red
highlight viraDetailsHighest ctermfg=darkred guifg=darkred
highlight viraDetailsLow ctermfg=darkgreen guifg=darkgreen
highlight viraDetailsLowest ctermfg=green guifg=green
highlight viraDetailsMedium ctermfg=darkyellow guifg=darkyellow
highlight viraDetailsStatusComplete ctermbg=green ctermfg=white guibg=green guifg=white
highlight viraDetailsStatusInProgress ctermbg=darkyellow ctermfg=black guibg=darkyellow guifg=black
highlight viraDetailsStatusTodo ctermbg=darkgrey ctermfg=white guibg=darkgrey guifg=white
highlight viraDetailsTypeBug ctermfg=red guifg=red
highlight viraDetailsTypeEpic ctermfg=grey guifg=grey
highlight viraDetailsTypeStory ctermfg=lightgreen guifg=lightgreen
highlight viraDetailsTypeTask ctermfg=darkblue guifg=darkblue
highlight viraItalic cterm=italic gui=italic
highlight viraLink cterm=underline gui=underline
highlight viraStrikethrough cterm=strikethrough gui=strikethrough
highlight viraUnderline cterm=underline gui=underline
highlight viraUsername cterm=underline gui=underline

let b:current_syntax = 'vira'
