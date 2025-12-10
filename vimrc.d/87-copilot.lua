if vim.g.VDP_CFG_PLUGIN_COPILOT_CHAT == "1" then
    require('CopilotChat').setup({
        window = {
            layout = 'vertical',
            width = 0.3,
        },
    })

    vim.keymap.set('n', '\\c', function()
        local splitright = vim.opt.splitright:get()
        vim.opt.splitright = true
        require('CopilotChat').toggle()
        vim.opt.splitright = splitright
    end, { desc = 'Toggle CopilotChat window' })
end
