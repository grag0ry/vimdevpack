if vim.g.VDP_CFG_PLUGIN_BLINK == "1" then

require('blink.cmp').setup {
    keymap = { preset = 'enter' },
    cmdline = { enabled = false },
}

end
