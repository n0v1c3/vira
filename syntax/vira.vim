" Quit when a syntax file was already loaded.
if exists('b:current_syntax') | finish|  endif

" Syntax matching
syntax match viraBold "\*.*\*"
syntax match viraBullets ".*\* "
syntax match viraCitvtion "??.*??"
syntax match viraCommentAuthor /.*@/hs=s,he=e contains=viraCommentDate nextgroup=viraCommentDate
syntax match viraCommentClose "}}}"
syntax match viraCommentDate /@.*/hs=s,he=e contained
syntax match viraTitleComment /Comments.*{{/hs=s,he=e contains=viraTitleFold nextgroup=viraTitleFold
syntax match viraTitleDescription /Description.*{{/hs=s,he=e contains=viraTitleFold nextgroup=viraTitleFold
syntax match viraItalic "_.*_"
syntax match viraLink "\[.*|.*\]"
syntax match viraMonospaced "{{.*}}"
syntax match viraPhoto "\!.*|.*\!"
syntax match viraStory "\v.*" contained
syntax match viraStrikethrough "-.*-"
syntax match viraSubscript "\~.*\~"
syntax match viraTheLine "----"
syntax match viraTitle "\%1l.*:" nextgroup=viraStory
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
highlight default link viraTitleComment Title
highlight default link viraTitleDescription Title
highlight default link viraMonospaced Question
highlight default link viraNoformat Normal
highlight default link viraPhoto Title
highlight default link viraStory Identifier
highlight default link viraSubscript Question
highlight default link viraTheLine Title
highlight default link viraTitle Title
highlight default link viraTitleFold Statement
highlight viraBold cterm=bold gui=bold
highlight viraItalic cterm=italic gui=italic
highlight viraLink cterm=underline gui=underline
highlight viraStrikethrough cterm=strikethrough gui=strikethrough
highlight viraUnderline cterm=underline gui=underline
highlight viraUsername cterm=underline gui=underline

let b:current_syntax = 'vira'
