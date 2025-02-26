function s:DetectOS()
    if (exists('$VIM_OS'))
        return $VIM_OS
    elseif has('win32unix')
        return 'cygwin'
    elseif has('win32')
        return 'windows'
    elseif has('macunix')
        return 'mac'
    elseif has('unix')
        if has('nvim')
            let uname_table = v:lua.vim.loop.os_uname()
            let uname = uname_table.sysname . " " . uname_table.release
        else
            let uname = system('uname -a')
        if (uname =~ "Microsoft")
            return 'wsl' " WSL 1
        elseif (uname =~ "microsoft")
            return 'wsl' " WSL 2
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
endfunction

let g:OS = s:DetectOS()

function g:PathSeparator()
    if g:OS == 'windows'
        return '\\'
    else
        return '/'
    endif
endfunction

let s:PathSeparator = g:PathSeparator()

if g:OS == "wsl"
    function PathWin2Lin(path)
        let l:res = system(["wslpath", "-u", a:path])
        if v:shell_error != 0
            throw "wslpath: " . l:res
        endif
        return trim(l:res)
    endfunction

    function PathLin2Win(path)
        let l:res = system(["wslpath", "-w", a:path])
        if v:shell_error != 0
            throw "wslpath: " . l:res
        endif
        return trim(l:res)
    endfunction
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
            let l:result .= s:PathSeparator
        endif
        let l:result .= l:p
    endfor
    return l:result
endfunction

function g:DirName(path)
    return fnamemodify(a:path, ':h')
endfunction

let s:path = fnamemodify(resolve(expand('<sfile>:p')), ':h')
let g:PackPath = resolve(g:JoinPath(s:path, '..'))
let g:PackCachePath = g:JoinPath(g:PackPath, 'cache')
let g:PackDevenvPath = g:JoinPath(g:PackPath, 'devenv')
let g:PackPluginGit = g:JoinPath(g:PackPath, 'plugin.git')
let g:PackPluginDir = g:JoinPath(g:PackPath, 'plugin.d')
if isdirectory(".git")
    let g:GitTopLevel = fnamemodify(resolve('.'), ':p')
else
    let g:GitTopLevel = g:DirName(finddir(".git", ".;"))
endif

function g:MakeCachePath(path)
    return g:JoinPath(g:PackCachePath, a:path)
endfunction

function g:MakeDevenvPath(path)
    return g:JoinPath(g:PackDevenvPath, a:path)
endfunction

execute 'source ' . fnameescape(g:JoinPath(g:PackDevenvPath, 'env.vim'))

