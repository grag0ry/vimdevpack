.PHONY: default
default: plugin lsp env tools

include common.mk
include plugin.mk
include dotnet.mk
include nodejs.mk
include rust.mk
include uv.mk

.PHONY: lsp env tools

# Plugins
$(call plugin-github,nvim-neo-tree/neo-tree.nvim.git)
$(call plugin-github,MunifTanjim/nui.nvim.git)
$(call plugin-github,bluz71/vim-moonfly-colors.git)
$(call plugin-github,junegunn/vim-plug.git)
$(call plugin-github,seblyng/roslyn.nvim)
$(call plugin-github,will133/vim-dirdiff.git)
$(call plugin-github,vim-scripts/mediawiki.vim.git)
$(call plugin-github,nvim-lua/plenary.nvim.git)
$(call plugin-github,nvim-lualine/lualine.nvim.git)
$(call plugin-github,nvim-telescope/telescope.nvim.git)
$(call plugin-github,nvim-tree/nvim-web-devicons.git)
$(call plugin-github,nvim-telescope/telescope-ui-select.nvim.git)
$(call plugin-github,dpezto/gnuplot.vim)
$(call plugin-github,nvim-treesitter/nvim-treesitter.git)
$(call plugin-github,f-person/git-blame.nvim.git)
$(call plugin-github,nvim-telescope/telescope-fzf-native.nvim.git)
$(call plugin-github,preservim/tagbar.git)
$(call plugin-github,rcarriga/nvim-notify.git)
$(call plugin-github,rafamadriz/friendly-snippets.git)
$(call plugin-github,neovim/nvim-lspconfig.git)
$(call plugin-github,vim-syntastic/syntastic.git)
$(call plugin-github,sindrets/diffview.nvim.git)
$(call plugin-local,dev)
$(call plugin-local,gtags)

plugin-telescope-fzf-native.nvim.git:
	$(MAKE) -C $(PLUGIN)/telescope-fzf-native.nvim.git

ifneq ($(CFG_PLUGIN_BLINK),)
ifeq ($(OS),Windows_NT)
BLINK_TOOLCHAIN=nightly-x86_64-pc-windows-gnu
else
BLINK_TOOLCHAIN=nightly
endif

$(call plugin-github,saghen/blink.cmp.git,v1)
$(call rustup-toolchain,plugin-blink.cmp.git,$(BLINK_TOOLCHAIN))
plugin-blink.cmp.git:
	cd $(PLUGIN)/blink.cmp.git && cargo +$(BLINK_TOOLCHAIN) build --release
endif # CFG_PLUGIN_BLINK

ifneq ($(CFG_PLUGIN_COPILOT_CHAT),)
ifeq ($(OS),Windows_NT)
LUA_TIKTOKEN_SRC=tiktoken_core-windows-x86_64-luajit.dll
LUA_TIKTOKEN=tiktoken_core.dll
else
LUA_TIKTOKEN_SRC=tiktoken_core-linux-x86_64-luajit.so
LUA_TIKTOKEN=tiktoken_core.so
endif
$(call plugin-github,CopilotC-Nvim/CopilotChat.nvim.git)

$(DEVENV)/liblua/$(LUA_TIKTOKEN): $(DEVENV)/liblua/.exists
	$(call github-assets,gptlang/lua-tiktoken,$@,$(LUA_TIKTOKEN_SRC))

plugin-CopilotChat.nvim.git: $(DEVENV)/liblua/$(LUA_TIKTOKEN)
$(call vimenv-add,lua package.cpath = package.cpath .. ";" .. vim.g.PackDevenvPath .. "/liblua/?.so")
endif # CFG_PLUGIN_COPILOT_CHAT

# Tools

ifneq ($(filter shellcheck,$(CFG_TOOLS)),)
ifeq ($(OS),Windows_NT)
$(DL)/shellcheck.zip:
	$(call github-assets,koalaman/shellcheck,$@,\.zip)

$(DEVENV)/shellcheck/shellcheck: $(DL)/shellcheck.zip
	mkdir -p "$(dir $@)"
	cd "$(dir $@)" && unzip -o "$(abspath $<)"
else
$(DL)/shellcheck.linux.x86_64.tar.xz:
	$(call github-assets,koalaman/shellcheck,$@,linux.x86_64)

$(DEVENV)/shellcheck/shellcheck: $(DL)/shellcheck.linux.x86_64.tar.xz
	mkdir -p "$(dir $@)"
	tar -C "$(dir $@)" -xvf "$(abspath $<)" --strip-components=1 --touch
endif

$(call linkbin,$(DEVENV)/shellcheck/shellcheck)
tools: $(BIN)/shellcheck
endif

ifneq ($(filter tree-sitter,$(CFG_TOOLS)),)
$(call npm,tree-sitter,tree-sitter-cli)
tools: $(BIN)/tree-sitter
endif

# LSP

ifneq ($(filter csharp-ls,$(CFG_LSP)),)
$(call dotnet-tool,csharp-ls)
lsp: $(BIN)/csharp-ls
endif

ifneq ($(filter powershell-es,$(CFG_LSP)),)
$(call dotnet-tool,pwsh,powershell)

$(DL)/PowerShellEditorServices.zip: $(DL)/.exists
	$(call github-assets,PowerShell/PowerShellEditorServices,$@,$(notdir $@))

$(call fake,powershell-es)
powershell-es: $(DL)/PowerShellEditorServices.zip
	mkdir -p "$(DEVENV)/powershell-es"
	cd "$(DEVENV)/powershell-es" && unzip -o "$(abspath $<)"

lsp: $(BIN)/pwsh $(fake-powershell-es)
endif

ifneq ($(filter pyright,$(CFG_LSP)),)
$(call npm,pyright-langserver,pyright)
lsp: $(BIN)/pyright-langserver
endif

ifneq ($(filter bash-language-server,$(CFG_LSP)),)
$(call npm,bash-language-server)
lsp: $(BIN)/bash-language-server
endif

ifneq ($(filter clangd,$(CFG_LSP)),)
$(DL)/clangd.zip:
ifeq ($(OS),Windows_NT)
	$(call github-assets,clangd/clangd,$@,clangd-windows)
else
	$(call github-assets,clangd/clangd,$@,clangd-linux)
endif

$(DEVENV)/clangd/bin/clangd: $(DL)/clangd.zip $(DEVENV)/.exists
	rm -rf "$(DEVENV)/clangd"
	mkdir -p "$(DEVENV)/clangd"
	cd "$(DEVENV)/clangd" && unzip -o "$(abspath $<)"
	mv -f "$(DEVENV)/clangd/"clangd_*/* "$(DEVENV)/clangd/"
	rm -rf "$(DEVENV)/clangd/"clangd_*
	touch "$@"

$(call linkbin,$(DEVENV)/clangd/bin/clangd,clangd)
lsp: $(BIN)/clangd
endif

ifneq ($(filter roslyn-ls,$(CFG_LSP)),)
$(DL)/roslyn-ls.zip:
ifeq ($(OS),Windows_NT)
	$(call github-assets,Crashdummyy/roslynLanguageServer,$@,win-x64)
else
	$(call github-assets,Crashdummyy/roslynLanguageServer,$@,linux-x64)
endif

$(call fake,roslyn-ls)
roslyn-ls: $(DL)/roslyn-ls.zip
	mkdir -p "$(DEVENV)/roslyn-ls"
	cd "$(DEVENV)/roslyn-ls" && unzip -o "$(abspath $<)"

lsp: $(fake-roslyn-ls)
endif

ifneq ($(filter ty,$(CFG_LSP)),)
$(call uv-tool,ty)
lsp: $(BIN)/ty
endif

ifneq ($(filter rust-analyzer,$(CFG_LSP)),)
ifeq ($(OS),Windows_NT)
RUST_ANALYZER_ARC = rust-analyzer-x86_64-pc-windows-msvc.zip
else
RUST_ANALYZER_ARC = rust-analyzer-x86_64-unknown-linux-gnu.gz
endif
$(DL)/$(RUST_ANALYZER_ARC):
	$(call github-assets,rust-lang/rust-analyzer,$@,$(notdir $@))

$(DEVENV)/rust-analyzer/rust-analyzer: $(DL)/$(RUST_ANALYZER_ARC)
	mkdir -p "$(dir $@)"
ifeq ($(OS),Windows_NT)
	cd "$(dir $@)" && unzip -o "$(abspath $<)"
else
	gunzip -k "$<" -c > "$@"
	chmod +x "$@"
endif

$(call linkbin,$(DEVENV)/rust-analyzer/rust-analyzer)
lsp: $(BIN)/rust-analyzer
endif

# Env

vim.env: $(CONFIG)
	@echo "Writing $@"
	$(file >$@,$(VIMENV))
	sed -i -e 's/\s*$$//' "$@"

env: vim.env

# Clean
.PHONY: clean
clean: clean-bin clean-plugin
	rm -rf $(DEVENV) vim.env

.PHONY: clean-cache
clean-cache:
	rm -rf $(CACHE)

.PHONY: clean-dl
clean-dl:
	rm -rf $(DL)

.PHONY: distclean
distclean: clean clean-dl

# Install

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

# Upgrade

.PHONY: upgrade-gtags
upgrade-gtags:
	$(call wget,https://cvs.savannah.gnu.org/viewvc/*checkout*/global/global/gtags.vim,plugin.d/gtags/plugin/gtags.vim) \
		|| git checkout plugin.d/gtags/plugin/gtags.vim

.PHONY: upgrade
upgrade:
	$(MAKE) clean
	$(MAKE)
