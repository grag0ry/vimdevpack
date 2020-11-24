nnoremap \h :SwitchSourceHeader<CR>
nnoremap \s :SplitSwitchSourceHeader<CR>
nnoremap \v :VSplitSwitchSourceHeader<CR>

syn match cCustomType "\<\w\+_t\>"

" stdint.h
syn keyword cType int8_t int16_t int32_t int64_t
syn keyword cType int_fast8_t  int_fast16_t  int_fast32_t  int_fast64_t
syn keyword cType int_least8_t int_least16_t int_least32_t int_least64_t
syn keyword cType intmax_t intptr_t
syn keyword cType uint8_t uint16_t uint32_t uint64_t
syn keyword cType uint_fast8_t  uint_fast16_t  uint_fast32_t  uint_fast64_t
syn keyword cType uint_least8_t uint_least16_t uint_least32_t uint_least64_t
syn keyword cType uintmax_t uintptr_t
