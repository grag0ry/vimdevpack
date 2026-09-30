if has("termguicolors")
    set termguicolors
else
    set t_Co=256
endif

syntax on

set cursorline
set hlsearch
set colorcolumn=81

if exists(':GuiFont')
    GuiFont DejaVuSansM Nerd Font Mono:h11
endif

colorscheme moonfly
if g:OS != "windows"
lua << EOF
    -- Highlight group 'NotifyBackground' has no background highlight
    vim.api.nvim_set_hl(0, "NotifyBackground", { bg = "#000000" })

    local parser_set = {}
    for _, p in ipairs(vim.g.VDP_TsParsers) do parser_set[p] = true end

    vim.api.nvim_create_autocmd('FileType', {
        pattern = "*",
        callback = function(ev)
            local lang = vim.treesitter.language.get_lang(ev.match)
            if lang and parser_set[lang] then
                pcall(vim.treesitter.start, ev.buf, lang)
            end
        end,
    })

    require'nvim-treesitter'.setup({ install_dir = vim.g.VDP_TsParsersDir })
EOF
endif
