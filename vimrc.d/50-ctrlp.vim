if has('nvim')
    fini
endif

let g:ctrlp_map = ''
let g:ctrlp_cache_dir = g:JoinPath(g:PackCachePath, "ctrlp")

if g:OS != 'windows'
    if (strlen(system('which fd 2>/dev/null')) != 0)
        let g:ctrlp_user_command = 'fd --full-path %s --type f'
    else
        let g:ctrlp_user_command = 'find %s -type f -not -path "*.vs/*"'
    endif
endif
