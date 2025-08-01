if exists('g:vimdevpack_util_loaded')
    fini
en
let g:vimdevpack_util_loaded = 1

function! s:WhichImpl(which, cmd)
    let l:res = system([a:which, a:cmd])
    if v:shell_error != 0
        throw "which: " . l:res
    endif
    return trim(l:res)
endfunction

if g:OS == "wsl"
    function s:WhichWin(cmd)
        return s:WhichImpl(PathWin2Lin("C:\\Windows\\System32\\where.exe"), a:cmd)
    endfunction
endif

function s:Which(cmd)
    if g:OS == 'windows'
        return s:WhichImpl("C:\\Windows\\System32\\where.exe", a:cmd)
    else
        return s:WhichImpl('which', a:cmd)
    endif
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

function! s:DoPrettyXML(l1, l2)
  " save the filetype so we can restore it later
  let l:origft = &ft
  let l:l1 = a:l1
  let l:l2 = a:l2
  set ft=
  " delete the xml header if it exists. This will
  " permit us to surround the document with fake tags
  " without creating invalid xml.
  exe l:l1 . "," . l:l2 . 's/<?xml .*?>//e'
  " insert fake tags around the entire document.
  " This will permit us to pretty-format excerpts of
  " XML that may contain multiple top-level elements.
  exe l:l1 - 1 . "put ='<PrettyXML>'"
  exe l:l2 + 1 . "put ='</PrettyXML>'"
  let l:l2 = l:l2 + 2
  exe 'silent ' . l:l1 . ',' . l:l2 . '!xmllint --format -'
  let l:l1 += 1
  let l:l2 = search("</PrettyXML>")
  " xmllint will insert an <?xml?> header. it's easy enough to delete
  " if you don't want it.
  " delete the fake tags
  exe l:l1 . 'd'
  let l:l2 -= 1
  exe l:l2 . 'd'
  let l:l2 -= 1
  " restore the 'normal' indentation, which is one extra level
  " too deep due to the extra tags we wrapped around the document.
  exe 'silent ' . l:l1 . ',' . l:l2 . '<'
  " back to home
  exe l:l1
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
    botright split
    exec "terminal " . l:cmd
endfunction

function! s:GtagsClearAll()
    for f in ["GTAGS", "GPATH", "GRTAGS"]
        echom 'Remove: ' . f . ' ' . (delete(f) == 0 ? 'SUCCEEDED' : 'FAILED')
    endfor
endfunction

" Escape/unescape & < > HTML entities in range (default current line).
function! HtmlEntities(line1, line2, action)
  let search = @/
  let range = 'silent ' . a:line1 . ',' . a:line2
  if a:action == 0  " must convert &amp; last
    execute range . 'sno/&lt;/</eg'
    execute range . 'sno/&gt;/>/eg'
    execute range . 'sno/&quot;/"/eg'
    execute range . 'sno/&apos;/''/eg'
    execute range . 'sno/&amp;/&/eg'
  else              " must convert & first
    execute range . 'sno/&/&amp;/eg'
    execute range . 'sno/</&lt;/eg'
    execute range . 'sno/>/&gt;/eg'
    execute range . 'sno/"/&quot;/eg'
    execute range . 'sno/''/&apos;/eg'
  endif
  nohl
  let @/ = search
endfunction

command! -range=% DelExtraWhitespace <line1>,<line2>s/\s\+$//e
command! -nargs=0 SwitchSourceHeader       call s:SwitchSourceHeader()
command! -nargs=0 SplitSwitchSourceHeader  call s:SplitSwitchSourceHeader()
command! -nargs=0 VSplitSwitchSourceHeader call s:VSplitSwitchSourceHeader()
command! -range=% PrettyXML call s:DoPrettyXML(<line1>, <line2>)
command! XxdToggle call s:XxdToggle()
command! SynStack call s:SynStack()
command! GtagsUpdateAll call s:GtagsUpdate()
command! GtagsClearAll call s:GtagsClearAll()
command! -complete=file -nargs=1 Remove :echom 'Remove: '.'<f-args>'.' '.(delete(<f-args>) == 0 ? 'SUCCEEDED' : 'FAILED')
command! -range -nargs=1 XmlEntities call HtmlEntities(<line1>, <line2>, <args>)
command! -nargs=1 Which :echom s:Which(<f-args>)
if g:OS == "wsl"
    command! -nargs=1 WhichWin :echom s:WhichWin(<f-args>)
endif

