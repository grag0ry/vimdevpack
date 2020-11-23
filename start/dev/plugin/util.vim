function! s:term_open()
    botright split
    terminal ++shell ++curwin ++noclose
endfunction

function! s:vterm_open()
    botright vsplit
    terminal ++shell ++curwin ++noclose
endfunction

function! s:Grep(args)
    copen
    cexpr system("grep -srnI " . a:args . " | sed -e 's/\r$//'")
endfunction

function! s:Find(args)
    copen
    cexpr system("find " . a:args . " -printf '%P:1:%Y\\n'")
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

command! -range=% DelExtraWhitespace <line1>,<line2>s/\s\+$//e
command! Term call s:term_open()
command! TermV call s:vterm_open()
command! -nargs=* -complete=file Grep call s:Grep(<q-args>)
command! -nargs=0 GrepCursor call s:Grep(expand("<cword>"))
command! -nargs=* -complete=file Find call s:Find(<q-args>)
command! -nargs=0 FindCursor call s:Find("-type f -name '*" . expand("<cword>") . "*'")
command! -nargs=0 SwitchSourceHeader       call s:SwitchSourceHeader()
command! -nargs=0 SplitSwitchSourceHeader  call s:SplitSwitchSourceHeader()
command! -nargs=0 VSplitSwitchSourceHeader call s:VSplitSwitchSourceHeader()
command! PrettyXML call s:DoPrettyXML()
