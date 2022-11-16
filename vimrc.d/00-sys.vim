let g:OS = 'unknown'

if (exists('$VIM_OS'))
    let g:OS = $VIM_OS
elseif has('win32unix')
    let g:OS = 'cygwin'
elseif has('win32')
    let g:OS = 'windows'
elseif has('macunix')
    let g:OS = 'mac'
elseif has('unix')
    let s:uname = system('uname -a')
    if (s:uname =~ "Microsoft")
        let g:OS = 'wsl' " WSL 1
    elseif (s:uname =~ "microsoft")
        let g:OS = 'wsl' " WSL 2
    elseif (s:uname =~ "Linux")
        let g:OS = 'linux'
    elseif (s:uname =~ "Darwin")
        let g:OS = 'mac'
    elseif (s:uname =~ "CYGWIN")
        let g:OS = 'cygwin'
    elseif (s:uname =~ "MINGW")
        let g:OS = 'windows'
    elseif (s:uname =~ "Msys")
        let g:OS = 'windows'
    endif
endif

if g:OS == 'windows'
    let s:PathSeparator = '\\'
else
    let s:PathSeparator = '/'
endif

function s:TrimPath(path, keepfull)
    if !len(a:path)
        return ""
    endif
    let l:start = 0
    let l:end = len(a:path) -1
    if !a:keepfull
        while a:path[l:start] == s:PathSeparator
            let l:start += 1
        endwhile
    endif
    while a:path[l:end] == s:PathSeparator
        let l:end -= 1
    endwhile
    if l:start >= l:end
        if a:keepfull
            return a:path[0]
        else
            return ""
        endif
    endif
    return a:path[l:start:l:end]
endfunction

function g:JoinPath(...)
    let l:result = s:TrimPath(a:000[0], v:true)
    for path in a:000[1:-1]
        let l:p = s:TrimPath(path, v:false)
        if !len(l:p) || l:p == s:PathSeparator
            continue
        endif
        if l:result != s:PathSeparator
            let l:result .= "/"
        endif
        let l:result .= l:p
    endfor
    return l:result
endfunction

let s:path = fnamemodify(resolve(expand('<sfile>:p')), ':h')
let g:PackPath = resolve(g:JoinPath(s:path, '..'))
let g:PackCachePath = g:JoinPath(g:PackPath, 'cache')

