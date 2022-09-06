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

function g:JoinPath(...)
    return join(a:000, s:PathSeparator)
endfunction

let s:path = fnamemodify(resolve(expand('<sfile>:p')), ':h')
let g:PackPath = resolve(g:JoinPath(s:path, '..'))
let g:PackCachePath = g:JoinPath(g:PackPath, 'cache')

