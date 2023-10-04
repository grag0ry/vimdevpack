if exists("b:current_syntax")
  finish
endif

syn case match

syn keyword prototextTodo contained TODO FIXME XXX
syn cluster prototextCommentGrp contains=protoTodo

syn keyword prototextBool    true false

syn match   prototextInt     /-\?\<\d\+\>/
syn match   prototextInt     /\<0[xX]\x+\>/
syn match   prototextFloat   /\<-\?\d*\(\.\d*\)\?/

syn region  prototextComment start="#" end="$" keepend contains=@prototextCommentGrp
syn region  prototextString  start=/"/ skip=/\\./ end=/"/
syn region  prototextString  start=/'/ skip=/\\./ end=/'/

syn match   prototextSep ":\|{"
syn match   prototextKey "\(\w\+\)\s*[:{]" contains=prototextSep

hi def link prototextBool    Boolean
hi def link prototextComment Comment
hi def link prototextString  String
hi def link prototextInt     Number
hi def link prototextFloat   Float
hi def link prototextKey     Type

let b:current_syntax = "proto-text"
