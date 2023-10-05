" vim: set filetype=ft
if exists('g:vimdevpack_vimrc_loaded')
    fini
en
let g:vimdevpack_vimrc_loaded = 1

scriptencoding utf-8

let s:inc = expand('<sfile>:h') . "/vimrc.d"
if exists("g:VimdevpackInclude")
    let s:inc = g:VimdevpackInclude
endif

let s:files = globpath(s:inc, '*.vim')
if has('nvim')
    let s:files .= "\n" . globpath(s:inc, '*.lua')
endif

for s:item in sort(split(s:files, '\n'))
    execute 'source ' . fnameescape(s:item)
endfor
