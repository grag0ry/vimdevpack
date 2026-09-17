local lsp = {}

local lsplist = {}

function lsp.config(name, opts)
    table.insert(lsplist, name)
    vim.lsp.config(name, opts or {})
end

function lsp.list()
    return lsplist
end

return lsp
