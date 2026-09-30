#!/bin/bash

set -e -u -o pipefail

vimenv=$(realpath "${1:?vimenv path required}")
readonly vimenv

nvim --headless --clean -l <(cat <<'LUA'
vim.cmd.source(arg[1])
vim.opt.runtimepath:append(vim.g.VDP_PluginPath .. "/nvim-treesitter.git")
require'nvim-treesitter'.setup({ install_dir = vim.g.VDP_TsParsersDir })
require'nvim-treesitter'.install(vim.g.VDP_TsParsers):wait(300000)
LUA
) "$vimenv"
