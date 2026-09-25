.PHONY: default env plugin lsp tools
.PHONY: update-plugin update-lsp update-tools
default: env plugin lsp tools

include libmk/common.mk
include libmk/plugin.mk
include libmk/rust.mk
include libmk/uv.mk
include libmk/dotnet.mk
include libmk/nodejs.mk

# Env

$(call vimenv-addvar-path,g:VDP_RootPath,$(CFG_PATH_PRJROOT))
$(call vimenv-addvar-path,g:VDP_DevenvPath,$(CFG_PATH_DEVENV))
$(call vimenv-addvar-path,g:VDP_CachePath,$(CFG_PATH_CACHE))
$(call vimenv-addvar-path,g:VDP_StatePath,$(CFG_PATH_STATE))
$(call vimenv-addvar-path,g:VDP_PluginPath,$(CFG_PATH_PLUGIN))
env: vim.env

# Plugins

$(call plugin-github,bluz71/vim-moonfly-colors.git)
$(call plugin-github,dpezto/gnuplot.vim)
$(call plugin-github,f-person/git-blame.nvim.git)
$(call plugin-github,junegunn/vim-plug.git)
$(call plugin-github,MunifTanjim/nui.nvim.git)
$(call plugin-github,neovim/nvim-lspconfig.git)
$(call plugin-github,nvim-lualine/lualine.nvim.git)
$(call plugin-github,nvim-lua/plenary.nvim.git)
$(call plugin-github,nvim-neo-tree/neo-tree.nvim.git)
$(call plugin-github,nvim-telescope/telescope-fzf-native.nvim.git)
$(call plugin-github,nvim-telescope/telescope.nvim.git)
$(call plugin-github,nvim-telescope/telescope-ui-select.nvim.git)
$(call plugin-github,nvim-tree/nvim-web-devicons.git)
$(call plugin-github,nvim-treesitter/nvim-treesitter.git)
$(call plugin-github,preservim/tagbar.git)
$(call plugin-github,rafamadriz/friendly-snippets.git)
$(call plugin-github,rcarriga/nvim-notify.git)
$(call plugin-github,seblyng/roslyn.nvim)
$(call plugin-github,sindrets/diffview.nvim.git)
$(call plugin-github,vim-scripts/mediawiki.vim.git)
$(call plugin-github,vim-syntastic/syntastic.git)
$(call plugin-github,will133/vim-dirdiff.git)
$(call plugin-local,dev)
$(call plugin-local,gtags)

plugin-telescope-fzf-native.nvim.git:
	$(MAKE) -C $(CFG_PATH_PLUGIN)/telescope-fzf-native.nvim.git

ifneq ($(CFG_PLUGIN_BLINK),)
ifeq ($(OS),Windows_NT)
BLINK_TOOLCHAIN=nightly-x86_64-pc-windows-gnu
else
BLINK_TOOLCHAIN=nightly
endif
$(call plugin-github,saghen/blink.cmp.git,v1)
$(call rustup-toolchain,plugin-blink.cmp.git,$(BLINK_TOOLCHAIN))
plugin-blink.cmp.git:
	$(call cargo,+$(BLINK_TOOLCHAIN) build --release \
		--manifest-path "$(CFG_PATH_PLUGIN)/blink.cmp.git/Cargo.toml")

update-plugin-blink.cmp.git: update-rustup
endif # CFG_PLUGIN_BLINK

ifneq ($(CFG_PLUGIN_COPILOT_CHAT),)
ifeq ($(OS),Windows_NT)
TIKTOKEN_SRC=tiktoken_core-windows-x86_64-luajit.dll
TIKTOKEN=$(CFG_PATH_DEVENV)/liblua/tiktoken_core.dll
else
TIKTOKEN_SRC=tiktoken_core-linux-x86_64-luajit.so
TIKTOKEN=$(CFG_PATH_DEVENV)/liblua/tiktoken_core.so
endif
.PHONY: update-liblua-tiktoken
update-liblua-tiktoken $(TIKTOKEN): | $(CFG_PATH_DEVENV)/liblua/.exists
	$(call github-assets,gptlang/lua-tiktoken,$(TIKTOKEN),$(TIKTOKEN_SRC))

$(call plugin-github,CopilotC-Nvim/CopilotChat.nvim.git)
plugin-CopilotChat.nvim.git: $(TIKTOKEN)
update-plugin-CopilotChat.nvim.git: update-liblua-tiktoken
$(call vimenv-add,lua package.cpath = package.cpath .. ";$(dir $(abspath $(TIKTOKEN)))?.so")
endif # CFG_PLUGIN_COPILOT_CHAT

# LSP

ifneq ($(filter ty,$(CFG_LSP)),)
$(call uv-tool,ty)
lsp: $(BIN)/ty
update-lsp: update-bin-ty
endif

ifneq ($(filter clangd,$(CFG_LSP)),)
ifeq ($(OS),Windows_NT)
$(call dl-github,clangd/clangd,clangd.zip,clangd-windows)
else
$(call dl-github,clangd/clangd,clangd.zip,clangd-linux)
endif
$(call arc,$(CFG_PATH_DL)/clangd.zip,$(CFG_PATH_DEVENV)/clangd,1)
$(call side-effects,$(fake-arc-clangd.zip),$(CFG_PATH_DEVENV)/clangd/bin/clangd)
$(call linkbin,$(CFG_PATH_DEVENV)/clangd/bin/clangd)
update-arc-clangd.zip: update-dl-clangd.zip
update-bin-clangd: update-arc-clangd.zip
lsp: $(BIN)/clangd
update-lsp: update-bin-clangd
endif # filter clangd,$(CFG_LSP)

ifneq ($(filter csharp-ls,$(CFG_LSP)),)
$(call dotnet-tool,csharp-ls)
lsp: $(BIN)/csharp-ls
update-lsp: update-bin-csharp-ls
endif

ifneq ($(filter powershell-es,$(CFG_LSP)),)
$(call dotnet-tool,powershell,pwsh)
$(call dl-github,PowerShell/PowerShellEditorServices,PowerShellEditorServices.zip,PowerShellEditorServices.zip)
$(call arc,$(CFG_PATH_DL)/PowerShellEditorServices.zip,$(CFG_PATH_DEVENV)/powershell-es)
update-arc-PowerShellEditorServices.zip: update-dl-PowerShellEditorServices.zip
lsp: $(BIN)/pwsh $(fake-arc-PowerShellEditorServices.zip)
update-lsp: update-bin-pwsh update-arc-PowerShellEditorServices.zip
endif # filter powershell-es,$(CFG_LSP)

ifneq ($(filter pyright,$(CFG_LSP)),)
$(call npm,pyright,pyright-langserver)
lsp: $(BIN)/pyright-langserver
update-lsp: update-bin-pyright-langserver
endif

ifneq ($(filter bash-language-server,$(CFG_LSP)),)
$(call npm,bash-language-server)
lsp: $(BIN)/bash-language-server
update-lsp: update-bin-bash-language-server
endif

ifneq ($(filter roslyn-ls,$(CFG_LSP)),)
ifeq ($(OS),Windows_NT)
$(call dl-github,Crashdummyy/roslynLanguageServer,roslyn-ls.zip,win-x64)
else
$(call dl-github,Crashdummyy/roslynLanguageServer,roslyn-ls.zip,linux-x64)
endif
$(call arc,$(CFG_PATH_DL)/roslyn-ls.zip,$(CFG_PATH_DEVENV)/roslyn-ls)
update-arc-roslyn-ls.zip: update-dl-roslyn-ls.zip
lsp: $(fake-arc-roslyn-ls.zip)
update-lsp: update-arc-roslyn-ls.zip
endif

ifneq ($(filter rust-analyzer,$(CFG_LSP)),)
ifeq ($(OS),Windows_NT)
RUST_ANALYZER = rust-analyzer.zip
$(call dl-github,rust-lang/rust-analyzer,$(RUST_ANALYZER),rust-analyzer-x86_64-pc-windows-msvc.zip)
else
RUST_ANALYZER = rust-analyzer.gz
$(call dl-github,rust-lang/rust-analyzer,$(RUST_ANALYZER),rust-analyzer-x86_64-unknown-linux-gnu.gz)
endif
$(call arc,$(CFG_PATH_DL)/$(RUST_ANALYZER),$(CFG_PATH_DEVENV)/rust-analyzer)
$(call side-effects,$(fake-arc-$(RUST_ANALYZER)),$(CFG_PATH_DEVENV)/rust-analyzer/rust-analyzer)
$(call linkbin,$(CFG_PATH_DEVENV)/rust-analyzer/rust-analyzer)
update-arc-$(RUST_ANALYZER): update-dl-$(RUST_ANALYZER)
update-bin-rust-analyzer: update-arc-$(RUST_ANALYZER)
lsp: $(BIN)/rust-analyzer
update-lsp: update-bin-rust-analyzer
endif

# Tools

ifneq ($(filter shellcheck,$(CFG_TOOLS)),)
ifeq ($(OS),Windows_NT)
$(call dl-github,koalaman/shellcheck,shellcheck.zip,\.zip)
$(call arc,$(CFG_PATH_DL)/shellcheck.zip,$(CFG_PATH_DEVENV)/shellcheck)
$(call side-effects,$(fake-arc-shellcheck.zip),$(CFG_PATH_DEVENV)/shellcheck/shellcheck)
$(call linkbin,$(CFG_PATH_DEVENV)/shellcheck/shellcheck)
update-arc-shellcheck.zip: update-dl-shellcheck.zip
update-bin-shellcheck: update-arc-shellcheck.zip
else
$(call dl-github,koalaman/shellcheck,shellcheck.tar.xz,linux.x86_64)
$(call arc,$(CFG_PATH_DL)/shellcheck.tar.xz,$(CFG_PATH_DEVENV)/shellcheck,1)
$(call side-effects,$(fake-arc-shellcheck.tar.xz),$(CFG_PATH_DEVENV)/shellcheck/shellcheck)
$(call linkbin,$(CFG_PATH_DEVENV)/shellcheck/shellcheck)
update-arc-: update-dl-shellcheck.tar.xz
update-bin-shellcheck: update-arc-shellcheck.tar.xz
endif
tools: $(BIN)/shellcheck
update-tools: update-bin-shellcheck
endif

ifneq ($(filter tree-sitter,$(CFG_TOOLS)),)
$(call npm,tree-sitter-cli,tree-sitter)
tools: $(BIN)/tree-sitter
update-tools: update-bin-tree-sitter
endif

# Common

.PHONY: clean clean-cache clean-dl distclean
clean: clean-lock clean-fake
	rm -rf vim.env "$(CFG_PATH_DEVENV)"

clean-cache:
	rm -rf "$(CFG_PATH_CACHE)"

clean-dl:
	rm -rf "$(CFG_PATH_DL)"

distclean: clean-dl clean

.PHONY: update
update: update-plugin update-lsp update-tools

.PHONY: install
install: export NVIM_VIMENV=$(call winpath,$(abspath vim.env))
install: export NVIM_VIMRC=$(call winpath,$(abspath vimrc))
install:
	mkdir -p "$(dir $(NVIM_CONFIG))"
	touch "$(NVIM_CONFIG)"
	sed -i -e '/vimdevpack/{:a;N;/endvimdevpack/!ba};/vimdevpack/d' "$(NVIM_CONFIG)"
	printf "%s\n" \
		"\" vimdevpack" \
		"exe 'source ' . fnameescape('$$NVIM_VIMENV')" \
		"exe 'source ' . fnameescape('$$NVIM_VIMRC')" \
		"\" endvimdevpack" \
	>> "$(NVIM_CONFIG)"

.PHONY: uninstall
uninstall:
	sed -i -e '/vimdevpack/{:a;N;/endvimdevpack/!ba};/vimdevpack/d' "$(NVIM_CONFIG)"
