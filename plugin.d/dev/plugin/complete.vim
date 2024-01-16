function! s:GetPathStart(line, end)
    let l:i = 0
    let l:stack = []
    let l:pairs = { '{' : '}', '[' : ']', '<' : '>', '(' : ')', '"' : '"', '`' : '`', "'" : "'" }
    while l:i < a:end
        if l:i > 0 && a:line[l:i - 1] == '\'
            let l:i += 1
            continue
        endif

        let l:c = a:line[l:i]
        let l:s = get(l:stack, -1, [-1, "none"])
        if l:s[1] == "word" && (l:c =~ '\s' || l:s[1] == l:c || has_key(l:pairs, l:c))
            unlet l:stack[-1]
        endif

        if l:s[1] == l:c
            unlet l:stack[-1]
        elseif has_key(l:pairs, l:c)
            let l:stack += [ [l:i + 1, l:pairs[l:c]] ]
        elseif l:s[1] != "word" && l:c =~ '\S'
            let l:stack += [ [l:i, "word"] ]
        endif

        let l:i += 1
    endwhile

    call reverse(l:stack)
    let l:res = get(l:stack, 0, [-1, "none"])
    for l:s in l:stack
        if (l:s[1] == '"' || l:s[1] == '`' || l:s[1] == "'")
            let l:res = l:s
            break
        endif
    endfor

    if 0 <= l:res[0] && l:res[0] < a:end
        return l:res[0]
    else
        return a:end
    endif
endfunction

function! CompletePath(findstart, base)
    if a:findstart
        let l:res = s:GetPathStart(getline('.'), col('.') - 1)
        return l:res
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

function! CompleteGtags(findstart, base)
    if a:findstart
        let l:line = getline('.')
        let l:start = col('.') - 1
        while l:start > 0 && l:line[l:start - 1] =~ '\a'
            let l:start -= 1
        endwhile
        return l:start
    endif
    return split(GtagsCandidate(a:base, a:base, 0), '\n')
endfunction

set completefunc=CompletePath
"set omnifunc=CompleteGtags
