let s:d = { n -> g:JoinPath(g:PackPluginDir, n) }
let s:g = { n -> g:JoinPath(g:PackPluginGit, n) }

function! s:_if(cond, ...)
    let opts = get(a:000, 0, {})
    return a:cond ? opts : extend(opts, { 'on': [], 'for': [] })
endfunction

exe 'source ' . fnameescape(g:JoinPath(g:PackPluginGit, "vim-plug", "plug.vim"))

call plug#begin()

call plug#(s:g("plenary.nvim"), s:_if(has('nvim')))
call plug#(s:g("nvim-web-devicons"), s:_if(has('nvim')))
call plug#(s:g("nvim-notify"), s:_if(has('nvim')))
call plug#(s:g("nui.nvim"), s:_if(has('nvim')))
call plug#(s:g("nvim-lspconfig"), s:_if(has('nvim')))
call plug#(s:g("nvim-treesitter"), s:_if(has('nvim'), {'do': ':TSUpdate'}))

call plug#(s:d('dev'))

call plug#(s:d("gtags"))
call plug#(s:g("tagbar"))
call plug#(s:g("syntastic"))

call plug#(s:g("vim-dirdiff"))
call plug#(s:g("diffview.nvim"), s:_if(has('nvim')))
call plug#(s:g("git-blame.nvim"), s:_if(has('nvim')))

call plug#(s:g("lualine.nvim"), s:_if(has('nvim')))

call plug#(s:g("telescope-fzf-native.nvim"), s:_if(has('nvim')))
call plug#(s:g("telescope.nvim"), s:_if(has('nvim')))

call plug#(s:g("neo-tree.nvim"), s:_if(has('nvim')))

call plug#(s:g("gnuplot.vim"))
call plug#(s:g("mediawiki.vim"))

call plug#(s:g("vim-moonfly-colors"), s:_if(has('nvim')))
call plug#(s:g("vim-cpp-enhanced-highlight"), s:_if(!has('nvim')))

call plug#(s:g("rust"), s:_if(0))

call plug#end()

