.PHONY: default
default: plugin lsp env tools

.PHONY: plugin lsp env tools

include common.mk
include dotnet.mk
include nodejs.mk

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

plugin: $(fake-submodule) $(fake-plugin-build) $(CACHE)/.exists $(CACHE)/undo/.exists

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

# Env

CLEAN += vim.env
vim.env: $(CONFIG)
	@echo "Writing $@"
	$(file >$@,$(VIMENV))

env: vim.env

# Clean
.PHONY: clean
clean:
	rm -rf $(CLEAN)

# Install

.PHONY: install
install: export NVIM_VIMENV=$(call winpath,$(abspath vim.env))
install: export NVIM_VIMRC=$(call winpath,$(abspath vimrc))
install:
	mkdir -p "$(dir $(NVIM_CONFIG))"
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
