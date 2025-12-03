-- common options applied to all servers
local common = {
  -- example: add your on_attach/capabilities here
  -- on_attach = my_on_attach,
  -- capabilities = my_capabilities,
}

-- list of servers and their specific options
local servers = {
--  csharp_ls     = {},
  clangd        = {},
  pyright       = {},
  bashls        = {},
  powershell_es = {
    bundle_path = vim.fn.MakeDevenvPath("powershell-es"),
  },
  roslyn = {
    cmd = {
      "dotnet",
      vim.fn.MakeDevenvPath("roslyn-ls/Microsoft.CodeAnalysis.LanguageServer.dll"),
      "--logLevel", -- this property is required by the server
      "Information",
      "--extensionLogDirectory", -- this property is required by the server
      vim.fn.MakeCachePath("roslyn-ls/logs"),
      "--stdio",
    },
  },
}

-- check if the new API is available
local has_new, newcfg = pcall(function() return vim.lsp.config end)
local lsp = has_new and newcfg or require("lspconfig")

if has_new then
  -- new style: register configs (servers will be enabled automatically when needed)
  for name, opts in pairs(servers) do
    local merged = vim.tbl_deep_extend("force", {}, common, opts)
    lsp[name] = merged
  end
else
  -- old style: defaults can be set via util.default_config
  lsp.util.default_config = vim.tbl_deep_extend("force", {}, lsp.util.default_config or {}, {
    autostart = false,
  })

  for name, opts in pairs(servers) do
    local merged = vim.tbl_deep_extend("force", {}, common, opts)
    lsp[name].setup(merged)
  end
end

