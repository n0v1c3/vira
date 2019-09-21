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

syntax match viraCode "\v\{code:.*\}\n.*\{code\}"
highlight default link viraCode Statement

syntax match viraBullets ".*\* "
highlight default link viraBullets Title

let b:current_syntax = 'vira'
