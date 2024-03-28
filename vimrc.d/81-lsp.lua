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

lspconfig.powershell_es.setup{
  bundle_path = vim.fn.MakeDevenvPath("opt/powershell-es")
}

--make --always-make --dry-run \
-- | grep -wE 'gcc|g\+\+' \
-- | grep -w '\-c' \
-- | jq -nR '[inputs|{directory:".", command:., file: match(" [^ ]+$").string[1:]}]' \
-- > compile_commands.json
