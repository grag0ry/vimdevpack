nnoremap <F2>  :set list!<CR>
nnoremap <F3>  :nohlsearch<CR>
nnoremap <F4>  :DelExtraWhitespace<CR>
nnoremap <F5>  :redraw!<CR>
nnoremap <F6>  :exec '!cd "'.expand('%:p:h').'" && bash'<CR>

nnoremap <C-c>      :cclose<CR>:lclose<CR>
nnoremap <C-]>      mP:GtagsCursor<CR>
nnoremap \g         mP:GrepCursor<CR>
nnoremap \f         mP:FindCursor<CR>
nnoremap <C-\><C-]> `P
nnoremap <C-j>      :cn<CR>
nnoremap <C-k>      :cp<CR>
nnoremap <C-\><C-j> :lnext<CR>
nnoremap <C-\><C-k> :lprevious<CR>
nnoremap <C-h>      :colder<CR>
nnoremap <C-l>      :cnewer<CR>

nnoremap \b    :CtrlPBuffer<CR>
nnoremap <c-f> :CtrlP<CR>

nnoremap \t :Term<CR>
nnoremap \T :TermV<CR>

nnoremap \\ :NERDTreeToggle<CR>
nnoremap \c :SyntasticCheck<CR>
nnoremap <C-\><C-c> :SyntasticReset<CR>

vnoremap _s :!sort 2>/dev/null<CR>
