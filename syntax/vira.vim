" Quit when a syntax file was already loaded.
if exists('b:current_syntax') | finish|  endif

syntax match simpleVar "\k\+" nextgroup=simpleAssignment
syntax match simpleAssignment "=" contained nextgroup=simpleValue
syntax match simpleValue ".*" contained nextgroup=viraOverview
syntax match viraCode "{code:java}.{code}" contained
highlight default link simpleVar Identifier
highlight default link simpleAssignment Statement
highlight default link simpleValue String
highlight default link viraCode Statement

syntax match viraCommentAuthor "\v.*\@" nextgroup=viraCommentDate
syntax match viraCommentDate "\v.*" contained
highlight default link viraCommentAuthor String
highlight default link viraCommentDate Statement

let b:current_syntax = 'vira'
