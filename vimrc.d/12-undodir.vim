set noswapfile
set nobackup
set nowritebackup

set undofile
let &undodir=g:JoinPath(g:VDP_StatePath, 'undo-nvim')
set undolevels=1000
set undoreload=10000
