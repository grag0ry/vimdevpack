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

    local types = {
        "c", "cpp", "c_sharp",
        "lua", "vim", "vimdoc", "query", "markdown", "markdown_inline",
        "xml",
        "python", "perl",
        "bash", "powershell",
        "dockerfile"
    }

    vim.api.nvim_create_autocmd('FileType', {
        pattern = types,
        callback = function() vim.treesitter.start() end,
    })

    vim.opt.runtimepath:prepend(vim.fn.MakeCachePath("treesitter-parsers"))
    require'nvim-treesitter'.setup {
        install_dir = vim.fn.MakeCachePath("treesitter-parsers"),
    }
    require'nvim-treesitter'.install(types)
EOF
endif
