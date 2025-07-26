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
    vim.opt.runtimepath:prepend(vim.fn.MakeCachePath("treesitter-parsers"))
    require'nvim-treesitter.configs'.setup {
        ensure_installed = {
            "c", "cpp", "c_sharp",
            "lua", "vim", "vimdoc", "query", "markdown", "markdown_inline",
            "xml",
            "python", "perl",
            "bash", "powershell"
        },
        highlight = {
            enable = true,
            -- Setting this to true will run `:h syntax` and tree-sitter at the same time.
            -- Set this to `true` if you depend on 'syntax' being enabled (like for indentation).
            -- Using this option may slow down your editor, and you may see some duplicate highlights.
            -- Instead of true it can also be a list of languages
            additional_vim_regex_highlighting = false,
        },
        parser_install_dir = vim.fn.MakeCachePath("treesitter-parsers"),
    }
EOF
endif
