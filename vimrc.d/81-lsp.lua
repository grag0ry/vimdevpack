-- vim: set tabstop=2 shiftwidth=2 expandtab:
local cfglsp = (vim.g.VDP_CFG_LSP or "") .. " " .. (vim.g.VDP_CFG_LSP_NATIVE or "")

for server in cfglsp:gmatch("%S+") do
  if server == "csharp-ls" then
    vim.lsp.config("csharp_ls", {})
  elseif server == "clangd" then
    vim.lsp.config("clangd", {})
  elseif server == "pyright" then
    vim.lsp.config("pyright", {})
  elseif server == "bash-language-server" then
    vim.lsp.config("bashls", {})
  elseif server == "powershell-es" then
    vim.lsp.config("powershell_es", {
      bundle_path = vim.fn.MakeDevenvPath("powershell-es"),
    })
  elseif server == "roslyn-ls" then
    vim.api.nvim_create_autocmd("SourcePost", {
      pattern = "*/plugin/roslyn.lua",  -- adjust to your plugin’s runtimepath
      once = true,
      callback = function()
        vim.lsp.enable('roslyn', false)
      end,
    })
    vim.lsp.config("roslyn", {
      cmd = {
        "dotnet",
        vim.fn.MakeDevenvPath("roslyn-ls/Microsoft.CodeAnalysis.LanguageServer.dll"),
        "--logLevel", -- this property is required by the server
        "Information",
        "--extensionLogDirectory", -- this property is required by the server
        vim.fn.MakeCachePath("roslyn-ls/logs"),
        "--stdio",
      },
    })
  elseif  server == "ty" then
    vim.lsp.config("ty", {})
  elseif server == "rust-analyzer" then
    vim.lsp.config("rust-analyzer", {
      cmd = { "rust-analyzer" },
      filetypes = { "rust" },
      root_dir = function(bufnr)
        local fname = vim.api.nvim_buf_get_name(bufnr)
        return vim.fs.dirname(vim.fs.find({ "Cargo.toml" }, { upward = true, path = fname })[1])
      end,
      settings = {
        ["rust-analyzer"] = {
          cargo = {
            allFeatures = true,
          },
          checkOnSave = {
            command = "clippy",
          },
        },
      },
    })
  end
end
