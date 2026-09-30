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
set completeopt=menu,menuone,noselect,noinsert,popup

" ident && tab
set tabstop=4
set shiftwidth=4
set smarttab
set expandtab
set smartindent

" search
set noincsearch

" list
set listchars=tab:>…,nbsp:⎵,trail:·
set list


lua << EOF
vim.provider.python = false
vim.provider.node = false
vim.provider.ruby = false
vim.provider.perl = false
vim.g.loaded_node_provider = 0
vim.g.loaded_perl_provider = 0
vim.g.loaded_ruby_provider = 0
vim.g.loaded_python3_provider = 0
EOF
