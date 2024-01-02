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

let s:files = filter(split(globpath(s:inc, '*.vim'), '\n'), 'v:val !~ "\.only\.vim$"')
if has('nvim')
    let s:files = s:files + split(globpath(s:inc, '*.lua'), '\n')
else
    let s:files = s:files + split(globpath(s:inc, '*.only.vim'), '\n')
endif

for s:item in sort(s:files)
    execute 'source ' . fnameescape(s:item)
endfor
