if vim.g.VDP_CFG_PLUGIN_COPILOT_CHAT == "1" then
    require('CopilotChat').setup({
        window = {
            layout = 'vertical',
            width = 0.3,
        },
    })
end
