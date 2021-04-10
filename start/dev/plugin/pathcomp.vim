function! CompletePath(findstart, base)
    if a:findstart
        let l:line  = getline('.')
        let l:start = col('.') - 1
        while l:start > 0 && !(l:line[l:start - 1] =~ "[\"'` \t]")
            let l:start -= 1
        endwhile
        return l:start
    endif

    let l:dirs = []
    if a:base != '' && a:base[0] == '/'
        let l:dirs += ['']
    else
        let l:dirs += [ expand('%:p:h') ]
        for l:d in split(&path, ',')
            if l:d != ''
                let l:dirs += [l:d]
            endif
        endfor
    endif

    for l:d in l:dirs
        let l:strip = strlen(l:d) + 1
        if l:d == ''
            let l:d = '/'
            let l:strip = 1
        endif
        for l:p in split(globpath(l:d, a:base . '*'), '\n')
            let l:variant = strpart(l:p, l:strip)
            if getftype(l:p) == "dir"
                let l:variant .= '/'
            endif
            call complete_add(l:variant)
        endfor
    endfor
    return []
endfunction

set completefunc=CompletePath

