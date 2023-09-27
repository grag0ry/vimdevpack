set noswapfile
set nobackup
set nowritebackup

set undofile
let &undodir=g:JoinPath(g:PackCachePath, 'undo')
set undolevels=1000
set undoreload=10000
