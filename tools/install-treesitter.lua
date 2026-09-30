vim.cmd.source(arg[1])
vim.opt.runtimepath:append(vim.g.VDP_PluginPath .. "/nvim-treesitter.git")
local setup_opts = {
    install_dir = vim.g.VDP_TsParsersDir
}
if vim.g.VDP_CFG_OSID == "msys2" then
    setup_opts.compilers = { vim.env.CC }
end
require('nvim-treesitter').setup(setup_opts)
require('nvim-treesitter').install(vim.g.VDP_TsParsers):wait(300000)
