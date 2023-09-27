set noswapfile
set nobackup
set nowritebackup

set undofile
if has("nvim")
    let &undodir=g:JoinPath(g:PackCachePath, 'undo-nvim')
else
    let &undodir=g:JoinPath(g:PackCachePath, 'undo')
endif
set undolevels=1000
set undoreload=10000
