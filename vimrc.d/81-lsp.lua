local lspconfig = require'lspconfig'

lspconfig.util.default_config = vim.tbl_extend(
    "force",
    lspconfig.util.default_config,
    { autostart = false }
)

lspconfig.csharp_ls.setup{}
lspconfig.clangd.setup{}
lspconfig.pyright.setup{}
lspconfig.bashls.setup{}
lspconfig.powershell_es.setup{
  bundle_path = vim.fn.MakeDevenvPath("powershell-es")
}

--make --always-make --dry-run \
-- | grep -wE 'gcc|g\+\+' \
-- | grep -w '\-c' \
-- | jq -nR '[inputs|{directory:".", command:., file: match(" [^ ]+$").string[1:]}]' \
-- > compile_commands.json
