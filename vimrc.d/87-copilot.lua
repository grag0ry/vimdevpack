if vim.g.VDP_CFG_PLUGIN_COPILOT_CHAT == "1" then
    require('CopilotChat').setup({
        window = {
            layout = 'vertical',
            width = 0.3,
        },
    })
end
if vim.g.VDP_CFG_PLUGIN_BLINK == "1" then

vim.api.nvim_create_autocmd('BufEnter', {
  pattern = { "copilot-chat", "copilot-chat-input" },
  callback = function() vim.b.completion = false end,
})


end
