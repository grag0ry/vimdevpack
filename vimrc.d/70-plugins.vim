let s:d = { n -> g:JoinPath(g:PackPluginDir, n) }
let s:g = { n -> g:JoinPath(g:PackPluginGit, n) }

function! s:_if(cond, ...)
    let opts = get(a:000, 0, {})
    return a:cond ? opts : extend(opts, { 'on': [], 'for': [] })
endfunction

exe 'source ' . fnameescape(g:JoinPath(g:PackPluginGit, "vim-plug", "plug.vim"))

call plug#begin()

call plug#(s:g("plenary.nvim"))
call plug#(s:g("nvim-web-devicons"))
call plug#(s:g("nvim-notify"))
call plug#(s:g("nui.nvim"))
call plug#(s:g("nvim-lspconfig"))
call plug#(s:g("nvim-treesitter"), s:_if(g:OS != "windows", {'do': ':TSUpdate'}))
call plug#(s:g("roslyn.nvim"))

call plug#(s:d('dev'))

call plug#(s:d("gtags"))
call plug#(s:g("tagbar"))
call plug#(s:g("syntastic"))

call plug#(s:g("vim-dirdiff"))
call plug#(s:g("diffview.nvim"))
call plug#(s:g("git-blame.nvim"))

call plug#(s:g("lualine.nvim"))

call plug#(s:g("telescope-fzf-native.nvim"))
call plug#(s:g("telescope.nvim"))

call plug#(s:g("neo-tree.nvim"))

call plug#(s:g("gnuplot.vim"))
call plug#(s:g("mediawiki.vim"))

call plug#(s:g("vim-moonfly-colors"))

call plug#end()

