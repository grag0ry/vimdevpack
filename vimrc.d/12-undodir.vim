set noswapfile
set nobackup
set nowritebackup

set undofile
let &undodir=g:JoinPath(g:PackStatePath, 'undo-nvim')
set undolevels=1000
set undoreload=10000
