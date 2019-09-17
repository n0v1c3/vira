" Quit when a syntax file was already loaded.
if exists('b:current_syntax') | finish|  endif

syntax match simpleVar "\k\+" nextgroup=simpleAssignment
syntax match simpleAssignment "=" contained nextgroup=simpleValue
syntax match simpleValue ".*" contained
highlight default link simpleVar Identifier
highlight default link simpleAssignment Statement
highlight default link simpleValue String

syntax match viraTitle "\%1l.*:" nextgroup=viraTitleStory
" syntax match viraTitleStory "\v|.*"
highlight default link viraTitle Title
" highlight default link viraTitleStory Statement

syntax match viraDescriptionTitle "\%2l.*:" nextgroup=viraDescriptionText
syntax match viraDescriptionText ".*Comments:"
highlight default link viraDescriptionTitle Title

syntax match viraCode "\v\{code:.*\}\n.*\{code\}"
highlight default link viraCode Statement

syntax match viraCommentTitle "Comments:" nextgroup=viraCommentAuthor
syntax match viraCommentAuthor "\v.*\@" nextgroup=viraCommentDate
syntax match viraCommentDate "\v.*" contained
highlight default link viraCommentTitle Title
highlight default link viraCommentAuthor String
highlight default link viraCommentDate Statement

let b:current_syntax = 'vira'
