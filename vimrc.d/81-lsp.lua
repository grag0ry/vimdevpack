local lspconfig = require'lspconfig'

lspconfig.util.default_config = vim.tbl_extend(
    "force",
    lspconfig.util.default_config,
    { autostart = false }
)

lspconfig.csharp_ls.setup{}

lspconfig.pyright.setup{
    cmd = { vim.fn.MakeCachePath("node_modules/.bin/pyright-langserver"), "--stdio" },
}

lspconfig.clangd.setup{}

