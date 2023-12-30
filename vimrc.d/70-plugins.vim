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

function s:plug_end()
    if s:manager == 'vim-plug'
        call plug#end()
    endif
endfunction

call s:plug_begin()
call s:plug("ctrlp")
call s:plug("dev")
call s:plug("gnuplot")
call s:plug("gtags")
call s:plug("mediawiki.vim")
call s:plug("nerdtree")
call s:plug("rust")
call s:plug("space-vim-dark")
call s:plug("syntastic")
call s:plug("tagbar")
call s:plug("vim-airline")
call s:plug("vim-airline-themes")
call s:plug("vim-cpp-enhanced-highlight")
call s:plug("vim-man")
call s:plug("vim-nerdtree-sync")
call s:plug_nvim("nvim-lspconfig")
call s:plug_end()
