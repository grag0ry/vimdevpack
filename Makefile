ECHO   = echo
GIT    = git
LN     = ln -sf
MKDIR  = mkdir -p
WGET   = wget
SED    = sed
TOUCH  = touch
DOTNET = $(dotnet-bin)
PYTHON = python
UNZIP  = unzip

mkpath     = $(realpath $(lastword $(MAKEFILE_LIST)))
curdir     = $(dir $(mkpath))
cachedir   = cache/
devenv     = devenv/
tools      = tools/
bindir     = $(devenv)bin/
link-native-bin = $(RM) $(bindir)$1 && $(LN) "$(shell which "$1")" "$(bindir)$1"
plugin-git = plugin.git/
plugin-dir = plugin.d/
new-path   = $(call winpath,$(patsubst %/,%,$(curdir)$(bindir)))

ifeq ($(OS),Windows_NT)
winpath = $(shell cygpath -w "$1")
linpath = $(shell cygpath -u "$1")
pathenvsep = ;
vim-cfg  = $(call linpath,$(USERPROFILE))/_vimrc
nvim-cfg = $(call linpath,$(LOCALAPPDATA))/nvim/init.vim
define link-bin =
$(ECHO) '@echo off' > "$(bindir)$(if $2,$2,$(notdir $1))"
	$(ECHO) 'call "$(call winpath,$(abspath $(1:%.bat=%.exe)))" %*' >> "$(bindir)$(if $2,$2,$(notdir $1))"
endef
MSYS = winsymlinks:native
export MSYS
else
winpath = $1
linpath = $1
pathenvsep = :
vim-cfg  = $(HOME)/.vimrc
nvim-cfg = $(HOME)/.config/nvim/init.vim
link-bin = $(RM) $(bindir)$(if $2,$2,$(notdir $1)) && $(LN) "../../$1" "$(bindir)$(if $2,$2,$(notdir $1))"
endif

-include config.mk

ifeq ($(CFG_TEST_NATIVE_TOOLS),1)
test-native = $(shell $(tools)test-native.sh $1)
CFG_DOTNET    ?= $(call test-native,dotnet 8)
CFG_CSHARP_LS ?= $(call test-native,csharp-ls)
CFG_CLANGD    ?= $(call test-native,clangd)
else
CFG_DOTNET    ?= local
CFG_CSHARP_LS ?= local
CFG_CLANGD    ?= local
endif

dotnet-version = 8.0
dotnet-root    = $(devenv)opt/dotnet-$(dotnet-version)/
ifeq ($(OS),Windows_NT)
dotnet-websrc  = https://dot.net/v1/dotnet-install.ps1
dotnet-install = $(devenv)dotnet-install.ps1
dotnet-bin     = $(bindir)dotnet.bat
dotnet-ins-cmd = powershell "$1" -InstallDir "$(dotnet-root)" -Channel $(dotnet-version)
dotnet-rid     = win-x64
else
dotnet-websrc  = https://dot.net/v1/dotnet-install.sh
dotnet-install = $(devenv)dotnet-install.sh
dotnet-bin     = $(bindir)dotnet
dotnet-ins-cmd = $(SHELL) "$1" --install-dir "$(dotnet-root)" --channel $(dotnet-version)
dotnet-rid     = linux-x64
endif

ifeq ($(CFG_DOTNET),local)
DOTNET_ROOT = $(call winpath,$(patsubst %/,%,$(curdir)$(dotnet-root)))
export DOTNET_ROOT
endif

target-cachedir = $(cachedir).exists
target-devenv = $(devenv).exists
target-bindir = $(bindir).exists
target-sm = $(devenv).sm-init
target-plugin = $(devenv).plugin-build

ifeq ($(OS),Windows_NT)
csharp-ls-bin = $(bindir)csharp-ls.bat
csharp-ls-exe = CSharpLanguageServer.exe
else
csharp-ls-bin = $(bindir)csharp-ls
csharp-ls-exe = CSharpLanguageServer
endif
csharp-ls-src = lsp/csharp-language-server/src/CSharpLanguageServer/
csharp-ls-dst = $(devenv)opt/csharp-ls/
csharp-ls-dep = $(wildcard $(csharp-ls-src)*.fs)

ifeq ($(OS),Windows_NT)
clangd-assets-filter = clangd-windows-[0-9.]+\.zip
clangd-version       = $(patsubst clangd-windows-%.zip,%,$(notdir $(clangd-url)))
clangd-bin           = $(bindir)clangd.bat
clangd-exe           = clangd.exe
else
clangd-assets-filter = clangd-linux-[0-9.]+\.zip
clangd-version       = $(patsubst clangd-linux-%.zip,%,$(notdir $(clangd-url)))
clangd-bin           = $(bindir)clangd
clangd-exe           = clangd
endif
clangd-github-repo = clangd/clangd
clangd-url-file    = $(devenv)clangd-url
clangd-url         = $(file <$(clangd-url-file))
clangd-unpack-dst  = $(devenv)opt/
clangd-dst         = $(clangd-unpack-dst)clangd_$(clangd-version)/bin/$(clangd-exe)

devenv-enviroment-vim = $(devenv)env.vim
devenv-enviroment-sh  = $(devenv)env.sh

gtags-websrc = https://cvs.savannah.gnu.org/viewvc/*checkout*/global/global/gtags.vim
gtags-dst = $(plugin-dir)gtags/plugin/gtags.vim

git-upgrade = $(tools)git-upgrade.sh
github-assets = $(tools)github-assets.py

.PHONY: all
all: sm plugin lsp $(target-cachedir) devenv-enviroment

$(target-cachedir):
	$(MKDIR) "$(dir $@)"
	$(TOUCH) "$@"

$(target-devenv):
	$(MKDIR) "$(dir $@)"
	$(TOUCH) "$@"

$(target-bindir): $(target-devenv)
	$(MKDIR) "$(dir $@)"
	$(TOUCH) "$@"

ifeq ($(CFG_DOTNET),local)
$(dotnet-install): $(target-devenv)
	$(WGET) "$(dotnet-websrc)" -O "$@"
	$(TOUCH) "$@"

$(dotnet-bin): $(dotnet-install) $(target-bindir)
	$(call dotnet-ins-cmd,$<)
	$(call link-bin,$(dotnet-root)$(notdir $@))
	$(TOUCH) "$@"
else
$(dotnet-bin): $(target-bindir)
	$(call link-native-bin,dotnet)
endif

$(target-sm): $(target-devenv) .gitmodules
	$(GIT) submodule update --init --recursive
	$(TOUCH) "$@"

.PHONY: sm
sm: $(target-sm)

$(target-plugin): $(target-sm) $(target-devenv)
	$(MAKE) -C $(plugin-git)telescope-fzf-native.nvim
	$(TOUCH) "$@"

ifeq ($(OS),Windows_NT)
$(target-plugin): export MSYSTEM=MSYS
endif

.PHONY: plugin
plugin: $(target-plugin)

ifeq ($(CFG_CSHARP_LS),local)
$(csharp-ls-bin): $(csharp-ls-dep) $(dotnet-bin) $(target-sm)
	$(DOTNET) build -c Release -r $(dotnet-rid) --self-contained=false -o "$(csharp-ls-dst)" "$(csharp-ls-src)"
	$(call link-bin,$(csharp-ls-dst)$(csharp-ls-exe),$(notdir $@))
	$(TOUCH) "$@"
else
$(csharp-ls-bin): $(target-bindir)
	$(call link-native-bin,csharp-ls)
endif

ifeq ($(CFG_CLANGD),local)
$(clangd-url-file): $(target-devenv)
	$(PYTHON) "$(github-assets)" -r "$(clangd-github-repo)" -f "$(clangd-assets-filter)" > "$@"

$(clangd-bin): $(clangd-url-file) $(target-cachedir)
	$(MKDIR) "$(clangd-unpack-dst)"
	$(WGET) "$(clangd-url)" -O "$(cachedir)$(notdir $(clangd-url))"
	( cd "$(clangd-unpack-dst)" && $(UNZIP) -o "$(curdir)$(cachedir)$(notdir $(clangd-url))" )
	$(call link-bin,$(clangd-dst),$(notdir $@))
	$(TOUCH) "$@"
else
$(clangd-bin): $(target-bindir)
	$(call link-native-bin,clangd)
endif

.PHONY: lsp
lsp: $(csharp-ls-bin) $(clangd-bin)

$(devenv-enviroment-vim): $(target-devenv)
ifeq ($(CFG_DOTNET),local)
	$(file >$@,let $$DOTNET_ROOT = '$(DOTNET_ROOT)')
	$(file >>$@,let $$PATH = '$(new-path)$(pathenvsep)' . $$PATH)
else
	$(file >$@,let $$PATH = '$(new-path)$(pathenvsep)' . $$PATH)
endif

$(devenv-enviroment-sh): $(target-devenv)
ifeq ($(CFG_DOTNET),local)
	$(file >$@,export $$DOTNET_ROOT = '$(DOTNET_ROOT)')
	$(file >>$@,export $$PATH = "$(new-path):$$PATH")
else
	$(file >$@,export $$PATH = "$(new-path):$$PATH")
endif

.PHONY: devenv-enviroment
devenv-enviroment: $(devenv-enviroment-vim) $(devenv-enviroment-sh)

define patch-vimrc =
$(TOUCH) "$1"
$(SED) -i -e '/vimdevpack/{:a;N;/endvimdevpack/!ba};/vimdevpack/d' "$1"
$(ECHO) '" vimdevpack' >> "$1"
$(ECHO) 'if filereadable('"'"'$(call winpath,$(curdir)vimrc)'"'"')' >> "$1"
$(ECHO) '    exe "source " . fnameescape('"'"'$(call winpath,$(curdir)vimrc)'"'"')' >> "$1"
$(ECHO) 'endif' >> "$1"
$(ECHO) '" endvimdevpack' >> "$1"
endef

.PHONY: install-vim
install-vim: all
	$(MKDIR) cache/undo
	$(call patch-vimrc,$(vim-cfg))

.PHONY: install-nvim
install-nvim: all
	$(MKDIR) cache/undo-nvim
	$(MKDIR) $(dir $(nvim-cfg))
	$(call patch-vimrc,$(nvim-cfg))

.PHONY: upgrade-sm
upgrade-sm: $(target-sm)
	$(GIT) submodule foreach '"$(curdir)$(git-upgrade)" "$(GIT)"'
	$(TOUCH) "$(target-sm)"

.PHONY: upgrade-gtags
upgrade-gtags:
	$(WGET) "$(gtags-websrc)" -O "$(gtags-dst)"
	$(TOUCH) "$(gtags-dst)"

.PHONY: upgrade
upgrade:
	$(MAKE) upgrade-sm
	$(MAKE) upgrade-gtags
	$(MAKE) --always-make all

