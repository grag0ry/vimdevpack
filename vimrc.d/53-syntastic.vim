let g:syntastic_always_populate_loc_list = 1
let g:syntastic_auto_loc_list = 1
let g:syntastic_check_on_wq = 0
let g:syntastic_mode_map = { 'mode': 'passive' }
let g:syntastic_enable_perl_checker = 1
let g:syntastic_perl_checkers = ["perl"]
let g:syntastic_cpp_compiler_options = "-std=c++17"

if has('nvim')
let g:syntastic_always_populate_loc_list = 0
let g:syntastic_auto_loc_list = 0
let g:syntastic_cursor_column = 0
let g:syntastic_enable_signs = 0
let g:syntastic_enable_balloons = 0
let g:syntastic_enable_highlighting = 0

function! SyntasticCheckHook(errors)
    call v:lua.SyntasticCallback(a:errors)
endfunction
endif
