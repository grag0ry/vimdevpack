function! s:term_open()
    botright split
    terminal ++shell ++curwin ++noclose
endfunction

function! s:vterm_open()
    botright vsplit
    terminal ++shell ++curwin ++noclose
endfunction

function! s:GrepCmd()
    if exists('g:GrepCmd')
        return g:GrepCmd
    endif

    " ripgrep
    :silent let g:GrepCmd = system('which rg 2>/dev/null')
    if (strlen(g:GrepCmd) != 0)
        let g:GrepCmd = trim(g:GrepCmd) . ' --vimgrep'
        return g:GrepCmd
    endif

    " normal grep
    :silent let g:GrepCmd = system('which grep 2>/dev/null')
    if (strlen(g:GrepCmd) != 0)
        let g:GrepCmd = trim(g:GrepCmd) . ' -srnI'
        return g:GrepCmd
    endif

    let g:GrepCmd = ''
    return g:GrepCmd
endfunction

function! s:Grep(...)
    let l:GrepCmd = s:GrepCmd()
    if (strlen(l:GrepCmd) == 0)
        echoerr "Grep command not found"
        return
    endif
    for arg in a:000
        let l:GrepCmd .= ' ' . shellescape(arg)
    endfor
    copen
    cexpr system(l:GrepCmd . " | sed -e 's/\\r$//'")
endfunction

function! s:Find(...)
    let l:FindCmd = 'find'
    for arg in a:000
        let l:FindCmd .= ' ' . shellescape(arg)
    endfor
    copen
    cexpr system(l:FindCmd . " -printf '%P:1:%Y\\n'")
endfunction

function! s:EditCppHeader()
    if (filereadable(expand("%:r") . ".h"))
        edit %:r.h
    else
        edit %:r.hpp
    endif
endfunction

function! s:EditCppSource()
    if (filereadable(expand("%:r") . ".cpp"))
        edit %:r.cpp
    else
        edit %:r.c
    endif
endfunction

function! s:SwitchSourceHeader()
    if (expand("%:e") == "cpp")
        call s:EditCppHeader()
    elseif (expand("%:e") == "c")
        call s:EditCppHeader()
    else
        call s:EditCppSource()
    endif
endfunction

function! s:SplitSwitchSourceHeader()
    split
    wincmd w
    call s:SwitchSourceHeader()
endfunction

function! s:VSplitSwitchSourceHeader()
    vsplit
    wincmd w
    call s:SwitchSourceHeader()
endfunction

function! s:DoPrettyXML()
  " save the filetype so we can restore it later
  let l:origft = &ft
  set ft=
  " delete the xml header if it exists. This will
  " permit us to surround the document with fake tags
  " without creating invalid xml.
  1s/<?xml .*?>//e
  " insert fake tags around the entire document.
  " This will permit us to pretty-format excerpts of
  " XML that may contain multiple top-level elements.
  0put ='<PrettyXML>'
  $put ='</PrettyXML>'
  silent %!xmllint --format -
  " xmllint will insert an <?xml?> header. it's easy enough to delete
  " if you don't want it.
  " delete the fake tags
  2d
  $d
  " restore the 'normal' indentation, which is one extra level
  " too deep due to the extra tags we wrapped around the document.
  silent %<
  " back to home
  1
  " restore the filetype
  exe "set ft=" . l:origft
endfunction

function! s:XxdToggle()
    if &filetype == "xxd"
        %!xxd -r
        if exists('b:old_filetype')
            exec 'set filetype=' . (b:old_filetype)
        endif
    else
        let b:old_filetype = &filetype
        %!xxd
        set filetype=xxd
    endif
endfunction

function! s:SynStack()
    if !exists("*synstack")
        return
    endif
    echo map(synstack(line('.'), col('.')), 'synIDattr(v:val, "name")')
endfunc

function! s:GtagsUpdate()
    if filereadable("GTAGS")
        let l:cmd = "global -uv"
    else
        let l:cmd = "gtags -v"
    endif
    exec "below terminal " . l:cmd
endfunction

function! s:GtagsClearAll()
    for f in ["GTAGS", "GPATH", "GRTAGS"]
        echom 'Remove: ' . f . ' ' . (delete(f) == 0 ? 'SUCCEEDED' : 'FAILED')
    endfor
endfunction

command! -range=% DelExtraWhitespace <line1>,<line2>s/\s\+$//e
command! Term call s:term_open()
command! TermV call s:vterm_open()
command! -nargs=* -complete=file Grep call s:Grep(<f-args>)
command! -nargs=0 GrepCursor call s:Grep(expand("<cword>"))
command! -nargs=* -complete=file Find call s:Find(<f-args>)
command! -nargs=0 FindCursor call s:Find("-type", "f", "-name", '*' . expand("<cword>") . '*')
command! -nargs=0 SwitchSourceHeader       call s:SwitchSourceHeader()
command! -nargs=0 SplitSwitchSourceHeader  call s:SplitSwitchSourceHeader()
command! -nargs=0 VSplitSwitchSourceHeader call s:VSplitSwitchSourceHeader()
command! PrettyXML call s:DoPrettyXML()
command! XxdToggle call s:XxdToggle()
command! SynStack call s:SynStack()
command! GtagsUpdateAll call s:GtagsUpdate()
command! GtagsClearAll call s:GtagsClearAll()
command! -complete=file -nargs=1 Remove :echom 'Remove: '.'<f-args>'.' '.(delete(<f-args>) == 0 ? 'SUCCEEDED' : 'FAILED')

