if has("termguicolors")
    set termguicolors
else
    set t_Co=256
endif

syntax on
colorscheme space-vim-dark

set cursorline
set hlsearch
set colorcolumn=81

" Fix colors
hi Normal          ctermbg=NONE guibg=NONE
hi LineNr          ctermbg=NONE guibg=NONE
hi SignColumn      ctermbg=NONE guibg=NONE
hi Comment         ctermfg=59   guifg=#5C6370
hi Conditional     cterm=NONE gui=NONE
hi Exception       cterm=NONE gui=NONE
hi Function        cterm=NONE gui=NONE
hi Directory       cterm=NONE gui=NONE
hi Repeat          cterm=NONE gui=NONE
hi Keyword         cterm=NONE gui=NONE
hi Structure       cterm=NONE gui=NONE
hi StorageClass    cterm=NONE gui=NONE
hi Statement       ctermfg=178 guifg=#D1951D
hi SpecialKey      ctermfg=59   guifg=#5C6370


hi Search    cterm=NONE gui=NONE ctermfg=35 guifg=#CACFD2 ctermbg=253 guibg=#009966
hi IncSearch cterm=NONE gui=NONE ctermfg=35 guifg=#CACFD2 ctermbg=253 guibg=#009966

hi cCustomClass    cterm=NONE gui=NONE ctermfg=128 guifg=#87AFFF

hi cppSTLexception cterm=NONE gui=NONE
hi cppSTLnamespace cterm=NONE gui=NONE ctermfg=128 guifg=#87AFFF
hi link cppException cppSTLexception
hi link cppAttribute cppExceptions

hi shSet           cterm=NONE gui=NONE
hi shLoop          cterm=NONE gui=NONE
hi shFunctionKey   cterm=NONE gui=NONE

hi NERDTreeCWD     cterm=NONE gui=NONE
hi NERDTreeUp      cterm=NONE gui=NONE
hi NERDTreeDir     cterm=NONE gui=NONE
hi NERDTreeDirSlash cterm=NONE gui=NONE
hi NERDTreeOpenable cterm=NONE gui=NONE
hi NERDTreeClosable cterm=NONE gui=NONE
hi NERDTreeExecFile cterm=NONE gui=NONE

hi vimLet     cterm=NONE gui=NONE
hi vimFuncKey cterm=NONE gui=NONE
hi vimCommand cterm=NONE gui=NONE
hi vimMap     cterm=NONE gui=NONE
hi vimGroup   cterm=NONE gui=NONE
hi vimHiGroup cterm=NONE gui=NONE

hi perlStatement    ctermfg=68  guifg=#4F97D7
hi perlFunctionName ctermfg=169 guifg=#BC6EC5
hi perlMethod       ctermfg=169 guifg=#BC6EC5

hi rustKeyword  cterm=NONE gui=NONE ctermfg=128 guifg=#87AFFF

if has('nvim')
    hi link @lsp.type.variable Normal
    hi link @lsp.type.parameter Float
endif
