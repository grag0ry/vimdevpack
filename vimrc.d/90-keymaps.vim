nnoremap <F2>  :set list!<CR>
nnoremap <F3>  :nohlsearch<CR>
nnoremap <F4>  :DelExtraWhitespace<CR>
nnoremap <F5>  :redraw!<CR>
nnoremap <F7>  :XxdToggle<CR>
nnoremap <F9>  :LspStart<CR>
nnoremap <F10>  :LspStop<CR>
nnoremap <F11>  :LspRestart<CR>
nnoremap <F12>  :LspInfo<CR>

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

nnoremap \b :Telescope buffers<CR>
nnoremap <c-f> :Telescope find_files<CR>
nnoremap \g :Telescope grep_string<CR>
nnoremap \f :LiveGrep<CR>
nnoremap <C-\><C-f> :LiveGrep ./
nnoremap \\ :NeotreeToggle<CR>
nnoremap \d :NeotreeCurrent<CR>
nnoremap \w :NeotreeBuffers<CR>
nnoremap <C-_> :Telescope current_buffer_fuzzy_find<CR>
nnoremap <C-\><C-\> :TagbarToggle<CR>
nnoremap \c :SyntasticCheck<CR>
lua vim.keymap.set('n', '<C-\\><C-c>', SyntasticReset)

vnoremap _s :!sort 2>/dev/null<CR>

inoremap <C-F> <C-X><C-U>
"inoremap <C-D> <C-X><C-O>

nnoremap <C-\><C-h> :DiffviewFileHistory %<CR>
vnoremap <buffer> <C-\><C-h> :DiffviewFileHistory<CR>
nnoremap <C-\><C-d> :DiffviewOpen<CR>
nnoremap <C-\><C-q> :DiffviewClose<CR>
nnoremap <C-\><C-a> :GitBlameToggle<CR>
nnoremap <C-\><C-z> :NeotreeGitstatus<CR>


lua <<EOF
vim.keymap.set('n', '<C-\\><C-s>', function()
    require('gitblame').get_sha(function(sha)
        require('vdp').diffview_sha(sha, '%')
    end)
end)

vim.keymap.set('n', '\\e', vim.diagnostic.open_float)
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev)
vim.keymap.set('n', ']d', vim.diagnostic.goto_next)
vim.keymap.set('n', '\\q', vim.diagnostic.setloclist)

if vim.g.VDP_CFG_PLUGIN_COPILOT_CHAT == "1" then
    vim.keymap.set('n', ']c', function()
        local splitright = vim.opt.splitright:get()
        vim.opt.splitright = true
        require('CopilotChat').toggle()
        vim.opt.splitright = splitright
    end, { desc = 'Toggle CopilotChat window' })
end

vim.api.nvim_create_autocmd('LspAttach', {
    group = vim.api.nvim_create_augroup('UserLspConfig', {}),
    callback = function(ev)
        local tb = require("telescope.builtin")
        local opts = { buffer = ev.buf, silent = true }

        vim.bo[ev.buf].omnifunc = 'v:lua.vim.lsp.omnifunc'

        vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, opts)
        vim.keymap.set('n', 'gd', tb.lsp_definitions, opts)
        vim.keymap.set('n', 'gi', tb.lsp_implementations, opts)
        vim.keymap.set('n', 'gr', function()
            tb.lsp_references({ include_declaration = false, show_line = true })
        end, opts)
        vim.keymap.set('n', '\\D', tb.lsp_type_definitions, opts)

        vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
        vim.keymap.set('n', '\\r', vim.lsp.buf.rename, opts)

        vim.keymap.set('n', 'gs', tb.lsp_document_symbols, { buffer = ev.buf, desc = "Document symbols" })
        vim.keymap.set('n', 'gS', tb.lsp_dynamic_workspace_symbols, {})
    end,
})

EOF
