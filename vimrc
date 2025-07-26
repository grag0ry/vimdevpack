" vim: set filetype=ft
if exists('g:vimdevpack_vimrc_loaded')
    fini
en
let g:vimdevpack_vimrc_loaded = 1

if !has('nvim')
    echoerr "nvim required"
    fini
en

scriptencoding utf-8

let s:inc = expand('<sfile>:h') . "/vimrc.d"
if exists("g:VimdevpackInclude")
    let s:inc = g:VimdevpackInclude
endif

let s:files = split(globpath(s:inc, '*.vim'), '\n')
          \ + split(globpath(s:inc, '*.lua'), '\n')

for s:item in sort(s:files)
    execute 'source ' . fnameescape(s:item)
endfor
