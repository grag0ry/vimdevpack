" vim: set filetype=ft
if exists('g:vimdevpack_vimrc_loaded')
    fini
en
let g:vimdevpack_vimrc_loaded = 1

scriptencoding utf-8

set term=xterm
set backspace=2 " make backspace work like most other apps
if has("termguicolors")
    set termguicolors
else
    set t_Co=256
endif
set mouse=a

set number
set ruler
set linebreak
set laststatus=2
set noshowmode " vim-airline does
filetype on

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

let s:inc = expand('<sfile>:h') . "/vimrc.d"
for s:item in sort(split(globpath(s:inc, '*.vim'), '\n'))
    execute 'source ' . fnameescape(s:item)
endfor
