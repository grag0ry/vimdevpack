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
        local lnum = (e.lnum ~= 0) and e.lnum - 1 or 0
        local end_lnum = (e.end_lnum ~= 0) and e.end_lnum - 1 or 0
        local col = (e.col ~= 0) and e.col - 1 or 0
        local end_col = (e.end_col ~= 0) and e.end_col - 1 or 0
        local key = tostring(e.bufnr)
        if diaglist[key] == nil then diaglist[key] = {} end
        table.insert(diaglist[key], {
            bufnr = e.bufnr,
            lnum = lnum,
            end_lnum = end_lnum,
            col = e.col,
            end_col = end_col,
            severity = severity_map[e["type"]] or severity_map["E"],
            message = e.text,
        })
    end
    local no_errors = true
    local show_qflist = false
    local currbuf = vim.fn.bufnr()
    for bufnr, list in pairs(diaglist) do
        vim.diagnostic.set(ns, tonumber(bufnr), list, nil)
        if bufnr ~= currbuf then show_qflist = true end
        no_errors = false
    end
    if no_errors then
        vim.diagnostic.reset(ns, currbuf)
    end
    if show_qflist then
        vim.diagnostic.setqflist()
    end
end

