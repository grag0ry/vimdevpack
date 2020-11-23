syntax on
colorscheme space-vim-dark

set termguicolors
set cursorline
set hlsearch
set colorcolumn=81

" Fix colors
hi Normal          ctermbg=NONE guibg=NONE
hi LineNr          ctermbg=NONE guibg=NONE
hi SignColumn      ctermbg=NONE guibg=NONE
hi Comment         ctermfg=59   guifg=#5C6370
hi ExtraWhitespace ctermbg=67 guibg=#5F87AF
hi Conditional     cterm=NONE gui=NONE
hi Exception       cterm=NONE gui=NONE
hi Function        cterm=NONE gui=NONE
hi Directory       cterm=NONE gui=NONE
hi Repeat          cterm=NONE gui=NONE
hi Keyword         cterm=NONE gui=NONE
hi Structure       cterm=NONE gui=NONE
hi StorageClass    cterm=NONE gui=NONE

hi Search    cterm=NONE gui=NONE
hi IncSearch cterm=NONE gui=NONE

hi cCustomClass    cterm=NONE gui=NONE ctermfg=128 guifg=#87afff

hi cppSTLexception cterm=NONE gui=NONE
hi cppSTLnamespace cterm=NONE gui=NONE

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

hi link cppException cppSTLexception
hi link cCustomType  Typedef
