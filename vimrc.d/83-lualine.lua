require('lualine').setup {
    sections = {
        lualine_a = {{'mode', fmt = function(str) return str:sub(1,1) end}},
        lualine_b = {'diagnostics'},
        lualine_c = {'filename'},
        lualine_x = {
                        'filetype',
                        {'encoding', separator = ""},
                        {
                            'fileformat',
                            padding = 0,
                            symbols = {unix = "LF ", dos = "CR LR ", mac = "CR "},
                        }
                    },
        lualine_y = {'progress'},
        lualine_z = {'location'}
    },
    extensions = {'quickfix', 'neo-tree'}
}
