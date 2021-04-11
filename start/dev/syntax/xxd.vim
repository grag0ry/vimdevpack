if exists("b:current_syntax")
  finish
endif
syn case match

syn match xxdSeparator contained ':'
syn match xxdDot       contained '[.\r]'
syn match xxdAddr      '^[0-9a-fA-F]\+:' contains=xxdSeparator
syn match xxdSubaddr   '\( [0-9a-fA-F]\{4\}\)\+'
syn match xxdStr       '.\{,16\}$' contains=xxdDot

hi def link xxdSeparator Statement
hi def link xxdDot       Keyword
hi def link xxdAddr      Number
hi def link xxdSubaddr   Float
hi def link xxdStr       String

let b:current_syntax = "xxd"
