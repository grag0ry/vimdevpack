local encoding_remap = {
    ["utf-8"] = "U8",
    ["utf-16le"] = "U16LE",
    ["utf-16be"] = "U16BE",
    ["utf-32le"] = "U32LE",
    ["utf-32be"] = "U32BE",
}
setmetatable(encoding_remap, {
    __index = function(table, key)
        return key
    end
})

local git_blame = require('gitblame')

require('lualine').setup {
    sections = {
        lualine_a = {
            {
                'mode',
                fmt = function(str) return str:sub(1,1) end
            }
        },
        lualine_b = {'diagnostics'},
        lualine_c = {
            {
                'filename',
                path = 1,
                on_click = function(n, b, m)
                    if n ~= 2 then
                        return
                    end
                    local bn = vim.api.nvim_get_current_buf()
                    local msg = vim.api.nvim_buf_get_name(bn)
                    vim.fn.setreg("+", msg)
                    vim.notify(msg, "info", {
                        title = "Full path",
                        animate = false,
                        render = "wrapped-compact",
                        hide_from_history = true
                    })
                end
            },
            {
                git_blame.get_current_blame_text,
                cond = git_blame.is_blame_text_available,
                on_click = function(n, b, m)
                    if n ~= 2 then
                        return
                    end
                    if b == "l" then
                        vim.cmd("GitBlameCopyCommitURL")
                    elseif b == "r" then
                        vim.cmd("GitBlameCopySHA")
                    else
                        return
                    end
                    vim.notify(vim.fn.getreg("+"), "info", {
                        title = "blame",
                        animate = false,
                        render = "wrapped-compact",
                        hide_from_history = true
                    })
                end
            }
        },
        lualine_x = {
                        'filetype',
                        {
                            'encoding',
                            separator = "",
                            fmt = function(str) return encoding_remap[str] end
                        },
                        {
                            'fileformat',
                            padding = 0,
                            symbols = {unix = " ", dos = " ", mac = " "},
                        }
                    },
        lualine_y = {'progress'},
        lualine_z = {'location'}
    },
    extensions = {'quickfix', 'neo-tree'}
}
