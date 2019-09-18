" Quit when a syntax file was already loaded.
if exists('b:current_syntax') | finish|  endif

syntax match viraTitle "\%1l.*:" nextgroup=viraStory
syntax match viraStory "\v.*" contained
highlight default link viraTitle Title
highlight default link viraStory Identifier

syntax match viraDescriptionTitle "Description:" nextgroup=viraDescription
highlight default link viraDescriptionTitle Title

syntax match viraCommentTitle "Comments:" nextgroup=viraCommentFold
syntax match viraCommentDate ".*{{{2" nextgroup=viraCommentAuthor
syntax match viraCommentAuthor ".*@"
highlight default link viraCommentTitle Title
highlight default link viraCommentAuthor Identifier
" highlight default link viraCommentAuthor String
highlight default link viraCommentDate Statement

syntax match viraCode "\v\{code:.*\}\n.*\{code\}"
highlight default link viraCode Statement

syntax match viraBullets ".*\* "
highlight default link viraBullets Title

" set foldexpr=(getline(v:lnum)=~g:vira_project)\\|\\|(getline(v:lnum)=~'Description:')?0:(getline(v:lnum)=~'-----')?'<2':3
" set foldmethod=expr
" set foldlevel=2
" set foldcolumn=1

let b:current_syntax = 'vira'
