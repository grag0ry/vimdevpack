require('telescope').setup {
    extensions = {
        fzf = {
            fuzzy = true,                    -- false will only do exact matching
            override_generic_sorter = true,  -- override the generic sorter
            override_file_sorter = true,     -- override the file sorter
            case_mode = "smart_case",        -- or "ignore_case" or "respect_case"
                                             -- the default case_mode is "smart_case"
        },
        ["ui-select"] = {
            require("telescope.themes").get_dropdown {}
        },
    },
    pickers = {
        diagnostics = {
            layout_strategy = 'vertical',
            layout_config = {width=0.9, height=0.9}
        },
        buffers = {
            sort_mru = true,
            layout_strategy = 'bottom_pane',
            layout_config = { prompt_position = "bottom" },
            path_display = { truncate = 3 },
            previewer = false
        }
    }
}

require('telescope').load_extension('fzf')
require('telescope').load_extension('ui-select')

vim.api.nvim_create_user_command('LiveGrep',
    function(opts)
        if next(opts.fargs) == nil then
            require('telescope.builtin').live_grep({prompt_title = vim.loop.cwd()})
        else
            require('telescope.builtin').live_grep({cwd = opts.fargs[1],
                                                    prompt_title = opts.fargs[1]})
        end
    end,
    { nargs = '?', complete = 'file' }
)


