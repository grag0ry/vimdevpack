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

set statusline=%<%f\ %h%m%r%=%-14.(%l,%c%V%)\ %P

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
let g:ctrlp_map = ''
let g:ctrlp_cache_dir = $HOME . "/.vim/pack/vimdevpack/cache/ctrlp"
