.PHONY: default
default: plugin lsp env tools

.PHONY: plugin lsp env tools

include common.mk
include dotnet.mk
include nodejs.mk
include rust.mk

# Plugins

$(call fake,submodule)
ifeq ($(UPGRADE),)
submodule:
	git submodule update --init --recursive
endif

$(call fake,plugin-build)
ifeq ($(OS),Windows_NT)
plugin-build: export MSYSTEM=MSYS
endif
plugin-build: $(fake-submodule)
	$(MAKE) -C plugin.git/telescope-fzf-native.nvim

plugin-clean:
	git submodule foreach git clean -fdx

plugin: $(fake-submodule) $(fake-plugin-build) $(CACHE)/.exists $(CACHE)/undo/.exists

ifneq ($(CFG_PLUGIN_COPILOT_CHAT),)
ifeq ($(OS),Windows_NT)
LUA_TIKTOKEN_SRC=tiktoken_core-windows-x86_64-luajit.dll
LUA_TIKTOKEN=tiktoken_core.dll
else
LUA_TIKTOKEN_SRC=tiktoken_core-linux-x86_64-luajit.so
LUA_TIKTOKEN=tiktoken_core.so
endif
$(DEVENV)/liblua/$(LUA_TIKTOKEN): $(DEVENV)/liblua/.exists
	$(call github-assets,gptlang/lua-tiktoken,$@,$(LUA_TIKTOKEN_SRC))

$(call vimenv-add,lua package.cpath = package.cpath .. ";" .. vim.g.PackDevenvPath .. "/liblua/?.so")

plugin-build: $(DEVENV)/liblua/$(LUA_TIKTOKEN)
endif

ifneq ($(CFG_PLUGIN_BLINK),)
$(call fake,plugin-blink)
$(call rustup-toolchain,plugin-blink,nightly)
plugin-blink: $(fake-submodule)
	cd plugin.git/blink.cmp && cargo +nightly build --release

plugin-build: $(fake-plugin-blink)
endif

# Tools

ifneq ($(filter shellcheck,$(CFG_TOOLS)),)
ifeq ($(OS),Windows_NT)
CLEAN += $(CACHE)/shellcheck.zip
$(CACHE)/shellcheck.zip:
	$(call github-assets,koalaman/shellcheck,$@,\.zip)

$(DEVENV)/shellcheck/shellcheck: $(CACHE)/shellcheck.zip
	mkdir -p "$(dir $@)"
	cd "$(dir $@)" && unzip -o "$(abspath $<)"
else
CLEAN += $(CACHE)/shellcheck.linux.x86_64.tar.xz
$(CACHE)/shellcheck.linux.x86_64.tar.xz:
	$(call github-assets,koalaman/shellcheck,$@,linux.x86_64)

$(DEVENV)/shellcheck/shellcheck: $(CACHE)/shellcheck.linux.x86_64.tar.xz
	mkdir -p "$(dir $@)"
	tar -C "$(dir $@)" -xvf "$(abspath $<)" --strip-components=1 --touch
endif

$(call linkbin,$(DEVENV)/shellcheck/shellcheck)
tools: $(BIN)/shellcheck
endif

ifneq ($(filter tree-sitter,$(CFG_TOOLS)),)
$(call nodejs-npm,tree-sitter,tree-sitter-cli)
tools: $(BIN)/tree-sitter
endif

# LSP

ifneq ($(filter csharp-ls,$(CFG_LSP)),)
$(call dotnet-tool,csharp-ls)
lsp: $(BIN)/csharp-ls
endif

ifneq ($(filter powershell-es,$(CFG_LSP)),)
$(call dotnet-tool,pwsh,powershell)

CLEAN += $(CACHE)/PowerShellEditorServices.zip
$(CACHE)/PowerShellEditorServices.zip: $(CACHE)/.exists
	$(call github-assets,PowerShell/PowerShellEditorServices,$@,$(notdir $@))

$(call fake,powershell-es)
powershell-es: $(CACHE)/PowerShellEditorServices.zip
	mkdir -p "$(DEVENV)/powershell-es"
	cd "$(DEVENV)/powershell-es" && unzip -o "$(abspath $<)"

lsp: $(BIN)/pwsh $(fake-powershell-es)
endif

ifneq ($(filter pyright,$(CFG_LSP)),)
$(call nodejs-npm,pyright-langserver,pyright)
lsp: $(BIN)/pyright-langserver
endif

ifneq ($(filter bash-language-server,$(CFG_LSP)),)
$(call nodejs-npm,bash-language-server)
lsp: $(BIN)/bash-language-server
endif

ifneq ($(filter clangd,$(CFG_LSP)),)
CLEAN += $(CACHE)/clangd.zip
$(CACHE)/clangd.zip:
ifeq ($(OS),Windows_NT)
	$(call github-assets,clangd/clangd,$@,clangd-windows)
else
	$(call github-assets,clangd/clangd,$@,clangd-linux)
endif

$(DEVENV)/clangd/bin/clangd: $(CACHE)/clangd.zip $(DEVENV)/.exists
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
CLEAN += $(CACHE)/roslyn-ls.zip
$(CACHE)/roslyn-ls.zip:
ifeq ($(OS),Windows_NT)
	$(call github-assets,Crashdummyy/roslynLanguageServer,$@,win-x64)
else
	$(call github-assets,Crashdummyy/roslynLanguageServer,$@,linux-x64)
endif

$(call fake,roslyn-ls)
roslyn-ls: $(CACHE)/roslyn-ls.zip
	mkdir -p "$(DEVENV)/roslyn-ls"
	cd "$(DEVENV)/roslyn-ls" && unzip -o "$(abspath $<)"

lsp: $(fake-roslyn-ls)
endif

# Env

CLEAN += vim.env
vim.env: $(CONFIG)
	@echo "Writing $@"
	$(file >$@,$(VIMENV))
	sed -i -e 's/\s*$$//' "$@"

env: vim.env

# Clean
.PHONY: clean
clean: plugin-clean
	rm -rf $(CLEAN)

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

.PHONY: upgrade-submodule
upgrade-submodule:
	git submodule foreach $(abspath "$(TOOLS)/git-upgrade.sh") git

.PHONY: upgrade-gtags
upgrade-gtags:
	$(call wget,https://cvs.savannah.gnu.org/viewvc/*checkout*/global/global/gtags.vim,plugin.d/gtags/plugin/gtags.vim) \
		|| git checkout plugin.d/gtags/plugin/gtags.vim

.PHONY: upgrade
upgrade:
	$(MAKE) upgrade-submodule
	$(MAKE) upgrade-gtags
	$(MAKE) clean
	$(MAKE) UPGRADE=1

.PHONY: upgrade-nosm
upgrade-nosm:
	$(MAKE) clean
	$(MAKE)
