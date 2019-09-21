" Quit when a syntax file was already loaded.
if exists('b:current_syntax') | finish|  endif

syntax match viraTitle "\%1l.*:" nextgroup=viraStory
syntax match viraStory "\v.*" contained
highlight default link viraTitle Title
highlight default link viraStory Identifier

syntax match viraDescriptionTitle "Description:" nextgroup=viraDescription
highlight default link viraDescriptionTitle Title

syntax match viraCommentTitle "Comments:" " nextgroup=viraCommentAuthor
syntax match viraCommentAuthor /.*@/hs=s,he=e contains=viraCommentDate nextgroup=viraCommentDate
syntax match viraCommentDate /@.*/hs=s,he=e contained
highlight default link viraCommentTitle Title
highlight default link viraCommentAuthor Identifier
highlight default link viraCommentDate Statement

syntax region viraCode start=/{code.*}/ end=/{code}/
highlight default link viraCode Question

syntax region viraNoformat start=/{noformat.*}/ end=/{noformat}/
highlight default link viraNoformat Normal

syntax match viraLink "\!.*|.*\!"
highlight default link viraLink Title

syntax match viraBold "\*.*\*"
highlight viraBold cterm=bold gui=bold

syntax match viraBullets ".*\* "
highlight default link viraBullets Identifier

syntax match viraItalic "_.*_"
highlight viraItalic cterm=italic gui=italic

syntax match viraUnderline "+.*+"
highlight viraUnderline cterm=underline gui=underline

syntax match viraStrikethrough "-.*-"
" highlight default link viraStrikethrough Error
highlight viraStrikethrough cterm=strikethrough gui=strikethrough

syntax match viraLine "----"
highlight default link viraLine Title

syntax match viraSubscript "\~.*\~"
highlight default link viraSubscript Question

syntax match viraCitvtion "??.*??"
highlight default link viraCitvtion Title

syntax match viraMonospaced "{{.*}}"
highlight default link viraMonospaced Question

syntax match viraUsername "\[\~.*\]"
highlight viraUsername cterm=underline gui=underline

syntax match viraLink "\[.*|.*\]"
highlight viraLink cterm=underline gui=underline

let b:current_syntax = 'vira'
