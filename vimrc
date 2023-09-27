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

for s:item in sort(split(globpath(s:inc, '*.vim'), '\n'))
    execute 'source ' . fnameescape(s:item)
endfor
