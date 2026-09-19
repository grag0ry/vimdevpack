let s:d = { n -> g:JoinPath(g:PackPluginDir, n) }
let s:g = { n -> g:JoinPath(g:PackPluginDir, n) }

function! s:_if(cond, ...)
    let opts = get(a:000, 0, {})
    return a:cond ? opts : extend(opts, { 'on': [], 'for': [] })
endfunction

exe 'source ' . fnameescape(g:JoinPath(g:PackPluginDir, "vim-plug.git", "plug.vim"))

call plug#begin()

call plug#(s:g("plenary.nvim.git"))
call plug#(s:g("nvim-web-devicons.git"))
call plug#(s:g("nvim-notify.git"))
call plug#(s:g("nui.nvim.git"))
call plug#(s:g("nvim-lspconfig.git"))
call plug#(s:g("nvim-treesitter.git"), s:_if(g:OS != "windows", {'do': ':TSUpdate'}))
call plug#(s:g("roslyn.nvim"))

call plug#(s:d('dev'))

call plug#(s:d("gtags"))
call plug#(s:g("tagbar.git"))
call plug#(s:g("syntastic.git"))

call plug#(s:g("vim-dirdiff.git"))
call plug#(s:g("diffview.nvim.git"))
call plug#(s:g("git-blame.nvim.git"))

call plug#(s:g("lualine.nvim.git"))

call plug#(s:g("telescope-fzf-native.nvim.git"))
call plug#(s:g("telescope-ui-select.nvim.git"))
call plug#(s:g("telescope.nvim.git"))

call plug#(s:g("blink.cmp.git"), s:_if(g:VDP_CFG_PLUGIN_BLINK == "1"))
call plug#(s:g("friendly-snippets.git"), s:_if(g:VDP_CFG_PLUGIN_BLINK == "1"))

call plug#(s:g("neo-tree.nvim.git"))

call plug#(s:g("gnuplot.vim"))
call plug#(s:g("mediawiki.vim.git"))

call plug#(s:g("vim-moonfly-colors.git"))

call plug#(s:g("CopilotChat.nvim.git"), s:_if(g:VDP_CFG_PLUGIN_COPILOT_CHAT == "1"))

call plug#end()

