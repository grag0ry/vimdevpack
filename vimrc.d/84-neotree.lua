require("neo-tree").setup({
    enable_git_status = false,
    filesystem = { hijack_netrw_behavior = "open_current" }
})

local cmd = {
    NeotreeToggle = 'Neotree source=filesystem position=left reveal toggle',
    NeotreeCurrent = function (args)
        local dir = vim.fn.expand('%:p:h')
        local cwd = vim.fn.getcwd()
        if dir:find(cwd, 1, true) == 1 then
            dir = 'reveal'
        end
        vim.cmd.Neotree({'source=filesystem', 'position=current', dir})
    end,
    NeotreeBuffers = 'Neotree source=buffers position=left reveal toggle',
    NeotreeGitstatus = 'Neotree source=git_status position=float reveal',
}

for k,v in pairs(cmd) do
    vim.api.nvim_create_user_command(k, v, {})
end
