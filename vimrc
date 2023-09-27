" vim: set filetype=ft
if exists('g:vimdevpack_vimrc_loaded')
    fini
en
let g:vimdevpack_vimrc_loaded = 1

scriptencoding utf-8

function s:include()
    if exists('g:VimdevpackInclude')
        return g:VimdevpackInclude
    else
        return expand('<sfile>:h') . "/vimrc.d"
    fi
endfunction

for s:item in sort(split(globpath(s:include(), '*.vim'), '\n'))
    execute 'source ' . fnameescape(s:item)
endfor
