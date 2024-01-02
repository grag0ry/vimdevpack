require("neo-tree").setup({
    enable_git_status = false,
    filesystem = { hijack_netrw_behavior = "open_current" }
})

local cmd = {
    NeotreeToggle = 'Neotree source=filesystem position=left reveal toggle',
    NeotreeCurrent = 'Neotree source=filesystem position=current reveal',
    NeotreeBuffers = 'Neotree source=buffers position=left reveal toggle',
    NeotreeGitstatus = 'Neotree source=git_status position=float reveal',
}

for k,v in pairs(cmd) do
    vim.api.nvim_create_user_command(k, v, {})
end
