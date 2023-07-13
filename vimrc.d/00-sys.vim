def DetectOS(): string
    if (exists('$VIM_OS'))
        return $VIM_OS
    elseif has('win32unix')
        return 'cygwin'
    elseif has('win32')
        return 'windows'
    elseif has('macunix')
        return 'mac'
    elseif has('unix')
        var uname = system('uname -a')
        if (uname =~ "Microsoft")
            return 'wsl' # WSL 1
        elseif (uname =~ "microsoft")
            return 'wsl' # WSL 2
        elseif (uname =~ "Linux")
            return 'linux'
        elseif (uname =~ "Darwin")
            return 'mac'
        elseif (uname =~ "CYGWIN")
            return 'cygwin'
        elseif (uname =~ "MINGW")
            return 'windows'
        elseif (uname =~ "Msys")
            return 'windows'
        endif
    endif
    return 'unknown'
enddef

const g:OS = DetectOS()

def g:PathSeparator(): string
    if g:OS == 'windows'
        return '\\'
    else
        return '/'
    endif
enddef

function s:TrimPath(path, keepfull)
    if !len(a:path)
        return ""
    endif
    let l:start = 0
    let l:end = len(a:path) -1
    if !a:keepfull
        while a:path[l:start] == PathSeparator()
            let l:start += 1
        endwhile
    endif
    while a:path[l:end] == PathSeparator()
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
        if !len(l:p) || l:p == PathSeparator()
            continue
        endif
        if l:result != PathSeparator()
            let l:result .= "/"
        endif
        let l:result .= l:p
    endfor
    return l:result
endfunction

let s:path = fnamemodify(resolve(expand('<sfile>:p')), ':h')
let g:PackPath = resolve(g:JoinPath(s:path, '..'))
let g:PackCachePath = g:JoinPath(g:PackPath, 'cache')

