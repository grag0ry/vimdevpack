vim.diagnostic.config({
    virtual_text = { severity = { min = vim.diagnostic.severity.INFO } }
})

local ns = vim.api.nvim_create_namespace("syntastic")
local severity_map = {
    I = vim.diagnostic.severity.INFO,
    W = vim.diagnostic.severity.WARN,
    E = vim.diagnostic.severity.ERROR,
}

function SyntasticReset()
    vim.cmd("SyntasticReset")
    vim.diagnostic.reset(ns, nil)
end

function SyntasticCallback(errlist)
    local diaglist = {}
    for _, e in ipairs(errlist) do
        lnum = (e.lnum ~= 0) and e.lnum - 1 or 0
        end_lnum = (e.end_lnum ~= 0) and e.end_lnum - 1 or 0
        col = (e.col ~= 0) and e.col - 1 or 0
        end_col = (e.end_col ~= 0) and e.end_col - 1 or 0
        if diaglist[e.bufnr] == nil then diaglist[e.bufnr] = {} end
        table.insert(diaglist[e.bufnr], {
            bufnr = e.bufnr,
            lnum = lnum,
            end_lnum = end_lnum,
            col = e.col,
            end_col = end_col,
            severity = severity_map[e["type"]] or severity_map["E"],
            message = e.text,
        })
    end
    local bufnr = vim.fn.bufnr()
    if #diaglist == 0 then
        vim.diagnostic.reset(ns, bufnr)
    else
        for bufnr, list in ipairs(diaglist) do
            vim.diagnostic.set(ns, bufnr, list, nil)
        end
    end
    vim.g.XXX = diaglist
    vim.g.XXX2 = errlist
end

