nnoremap <F2>  :set list!<CR>
nnoremap <F3>  :nohlsearch<CR>
nnoremap <F4>  :DelExtraWhitespace<CR>
nnoremap <F5>  :redraw!<CR>
nnoremap <F6>  :exec '!cd "'.expand('%:p:h').'" && bash'<CR>
nnoremap <F7>  :XxdToggle<CR>
if has('nvim')
    nnoremap <F9>  :LspStart<CR>
    nnoremap <F10>  :LspStop<CR>
    nnoremap <F11>  :LspRestart<CR>
    nnoremap <F12>  :LspInfo<CR>
endif

noremap _y "+y
noremap _p "+p

nnoremap <C-c>      :cclose<CR>:lclose<CR>
nnoremap <C-]>      mP:GtagsCursor<CR>
nnoremap <C-LeftMouse> mP:GtagsCursor<CR>
nnoremap <C-\><C-]> `P
nnoremap <C-RightMouse> `P
nnoremap <C-j>      :cn<CR>
nnoremap <C-k>      :cp<CR>
nnoremap <C-\><C-j> :lnext<CR>
nnoremap <C-\><C-k> :lprevious<CR>
nnoremap <C-h>      :colder<CR>
nnoremap <C-l>      :cnewer<CR>

nnoremap \t :Term<CR>
nnoremap \T :TermV<CR>

if has('nvim')
    nnoremap \b :Telescope buffers<CR>
    nnoremap <c-f> :Telescope find_files<CR>
    nnoremap \g :Telescope grep_string<CR>
    nnoremap \f :LiveGrep<CR>
    nnoremap <C-\><C-f> :LiveGrep ./
    nnoremap \\ :NeotreeToggle<CR>
    nnoremap \d :NeotreeCurrent<CR>
    nnoremap \w :NeotreeBuffers<CR>
    nnoremap \z :NeotreeGitstatus<CR>
    nnoremap <C-_> :Telescope current_buffer_fuzzy_find<CR>
else
    nnoremap \b    :CtrlPBuffer<CR>
    nnoremap <c-f> :CtrlP<CR>
    nnoremap \\ :NERDTreeToggle<CR>
    nnoremap \d :exec 'edit ' . expand('%:p:h')<CR>
    nnoremap \g mP:GrepCursor<CR>
    nnoremap \f mP:FindCursor<CR>
endif
nnoremap <C-\><C-\> :TagbarToggle<CR>
nnoremap \c :SyntasticCheck<CR>
if has('nvim')
    lua vim.keymap.set('n', '<C-\\><C-c>', SyntasticReset)
else
    nnoremap <C-\><C-c> :SyntasticReset<CR>
endif

vnoremap _s :!sort 2>/dev/null<CR>

inoremap <C-F> <C-X><C-U>
"inoremap <C-D> <C-X><C-O>

if has('nvim')
lua <<EOF

vim.keymap.set('n', '\\e', vim.diagnostic.open_float)
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev)
vim.keymap.set('n', ']d', vim.diagnostic.goto_next)
vim.keymap.set('n', '\\q', vim.diagnostic.setloclist)

vim.api.nvim_create_autocmd('LspAttach', {
    group = vim.api.nvim_create_augroup('UserLspConfig', {}),
    callback = function(ev)
        vim.bo[ev.buf].omnifunc = 'v:lua.vim.lsp.omnifunc'
        local opts = { buffer = ev.buf }
        vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, opts)
        vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
        vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
        vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, opts)
        -- vim.keymap.set('n', '<C-k>', vim.lsp.buf.signature_help, opts)
        vim.keymap.set('n', '\\D', vim.lsp.buf.type_definition, opts)
        vim.keymap.set('n', '\\r', vim.lsp.buf.rename, opts)
        vim.keymap.set('n', 'gr', vim.lsp.buf.references, opts)
    end,
})

EOF
endif
