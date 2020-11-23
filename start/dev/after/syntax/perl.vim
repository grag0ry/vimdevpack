let &l:includeexpr='substitute(v:fname, "::", "/", "g").".pm"'
let &path.="lib/"
vnoremap _t :!perltidy 2>/dev/null<CR>
vnoremap _d :!perl -MO=Deparse,-p 2>/dev/null<CR>
"Perl convert ->{'xxx'} in ->{xxx} and 'xxx' => foo() in xxx => foo()
vnoremap _q :!sed
    \ -e 's/->{\s*'"'"'\([a-z0-9_]\+\)'"'"'\s*}/->{\1}/gi'
    \ -e 's/'"'"'\([a-z0-9_]\+\)'"'"'\(\s*=>\s*\)/\1\2/gi'
    \ 2>/dev/null<CR>

