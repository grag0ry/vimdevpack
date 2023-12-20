local lspconfig = require'lspconfig'

lspconfig.util.default_config = vim.tbl_extend(
    "force",
    lspconfig.util.default_config,
    { autostart = false }
)

lspconfig.omnisharp.setup{
    cmd = { vim.fn.MakeCachePath("omnisharp/net6/OmniSharp") },
}
lspconfig.pyright.setup{
    cmd = { vim.fn.MakeCachePath("node_modules/.bin/pyright-langserver"), "--stdio" },
}


