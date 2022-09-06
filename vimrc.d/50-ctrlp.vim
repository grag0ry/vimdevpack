let g:ctrlp_map = ''
let g:ctrlp_cache_dir = g:JoinPath(g:PackCachePath, "ctrlp")

if g:OS != 'windows'
    let g:ctrlp_user_command = 'find %s -type f -not -path "*.vs/*"'
endif
