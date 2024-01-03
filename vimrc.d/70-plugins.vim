function s:get_manager()
    if exists("g:VimdevpackPluginManager")
        return g:VimdevpackPluginManager
    elseif has('nvim')
        return "vim-plug"
    else
        return "native"
    endif
endfunction

let s:manager = s:get_manager()

function s:plug_begin()
    if s:manager == 'vim-plug'
        exe 'source ' . fnameescape(g:JoinPath(g:PackPluginPath, "vim-plug", "plug.vim"))
        exe "call plug#begin()"
    endif
endfunction

function s:plug(name)
    if s:manager == 'vim-plug'
        call plug#(g:JoinPath(g:PackPluginPath, a:name))
    elseif s:manager == 'native'
        exe "packadd " . a:name
    endif
endfunction

function s:plug_nvim(name)
    if has('nvim')
        if s:manager == 'vim-plug'
            call plug#(g:JoinPath(g:PackPluginPathNvim, a:name))
        elseif s:manager == 'native'
            exe "packadd " . a:name
        endif
    endif
endfunction

function s:plug_vim(name)
    if !has('nvim')
        call s:plug(a:name)
    endif
endfunction

function s:plug_end()
    if s:manager == 'vim-plug'
        call plug#end()
    endif
endfunction

call s:plug_begin()
call s:plug("dev")
call s:plug("gnuplot")
call s:plug("gtags")
call s:plug("mediawiki.vim")
call s:plug("rust")
call s:plug("tagbar")
call s:plug("syntastic")
call s:plug("vim-cpp-enhanced-highlight")
call s:plug_vim("ctrlp")
call s:plug_vim("space-vim-dark")
call s:plug_vim("vim-airline")
call s:plug_vim("vim-airline-themes")
call s:plug_vim("nerdtree")
call s:plug_vim("vim-nerdtree-sync")
call s:plug_vim("vim-man")
call s:plug_nvim("plenary.nvim")
call s:plug_nvim("nvim-web-devicons")
call s:plug_nvim("nvim-notify")
call s:plug_nvim("nui.nvim")
call s:plug_nvim("nvim-lspconfig")
call s:plug_nvim("lualine.nvim")
call s:plug_nvim("neo-tree.nvim")
call s:plug_nvim("telescope-fzf-native.nvim")
call s:plug_nvim("telescope.nvim")
call s:plug_nvim("vim-moonfly-colors")
call s:plug_end()
