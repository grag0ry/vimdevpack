" vim: set filetype=ft
if exists('g:vimdevpack_vimrc_loaded')
    fini
en
let g:vimdevpack_vimrc_loaded = 1

scriptencoding utf-8

set term=xterm
set backspace=2 " make backspace work like most other apps
set t_Co=256

set number
set ruler
set linebreak
set laststatus=2
set noshowmode " vim-airline does

" autocomplete
set wildmode=longest,list,full
set wildmenu

" ident && tab
set tabstop=4
set shiftwidth=4
set smarttab
set expandtab
set smartindent

"history
set noswapfile
set nobackup
set nowritebackup

" enable project specific
set exrc
set secure

" plugin config
" ctrlp
let g:ctrlp_map = ''
let g:ctrlp_cache_dir = $HOME . "/.vim/pack/vimdevpack/cache/ctrlp"

" netrw
let g:netrw_liststyle = 3
let g:netrw_altv = 1
let g:netrw_browse_split = 4
let g:netrw_banner = 0

" nerd tree
let g:NERDTreeHighlightCursorline = 1
let g:nerdtree_sync_cursorline = 1

" syntastic
let g:syntastic_always_populate_loc_list = 1
let g:syntastic_auto_loc_list = 1
let g:syntastic_check_on_wq = 0
let g:syntastic_mode_map = { 'mode': 'passive' }
let g:syntastic_enable_perl_checker = 1
let g:syntastic_perl_checkers = ["perl"]
let g:syntastic_cpp_compiler_options = "-std=c++17"

" vim-cpp-enhanced-highlight
let g:cpp_posix_standard = 1
let g:cpp_class_decl_highlight = 1
let g:cpp_class_scope_highlight = 1

" vim-airline
let g:airline_theme='violet'
let g:airline_mode_map = {
    \ '__'     : '-',
    \ 'c'      : 'C',
    \ 'i'      : 'I',
    \ 'ic'     : 'I',
    \ 'ix'     : 'I',
    \ 'n'      : 'N',
    \ 'multi'  : 'M',
    \ 'ni'     : 'N',
    \ 'no'     : 'N',
    \ 'R'      : 'R',
    \ 'Rv'     : 'R',
    \ 's'      : 'S',
    \ 'S'      : 'S',
    \ ''       : 'S',
    \ 't'      : 'T',
    \ 'v'      : 'V',
    \ 'V'      : 'V',
    \ ''     : 'V',
    \ }
if !exists('g:airline_symbols')
    let g:airline_symbols = {}
endif
let g:airline_symbols.maxlinenr = ''
let g:airline_symbols.linenr = ''
let g:airline_symbols_ascii = 1

