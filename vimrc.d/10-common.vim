"set term=xterm
set backspace=2 " make backspace work like most other apps
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

" list
set listchars=tab:……,nbsp:⎵,trail:·
set list

" enable project specific
" set exrc
" set secure

