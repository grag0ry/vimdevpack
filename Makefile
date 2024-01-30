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
link-bin   = $(RM) $(bindir)$(if $2,$2,$(notdir $1)) && $(LN) "../../$1" "$(bindir)$(if $2,$2,$(notdir $1))"
link-native-bin = $(RM) $(bindir)$1 && $(LN) "$(shell which "$1")" "$(bindir)$1"
plugin-git = plugin.git/
plugin-dir = plugin.d/
new-path += $(patsubst %/,%,$(curdir)$(bindir))

ifeq ($(CFG_FORCE_NATIVE_TOOLS),1)
test-native = $(shell $(tools)test-native.sh $1)
CFG_DOTNET    ?= $(call test-native,dotnet 8)
CFG_CSHARP_LS ?= $(call test-native,csharp-ls)
CFG_CLANGD    ?= $(call test-native,clangd)
else
CFG_DOTNET    ?= local
CFG_CSHARP_LS ?= local
CFG_CLANGD    ?= local
endif

dotnet-websrc  = https://dot.net/v1/dotnet-install.sh
dotnet-install = $(devenv)dotnet-install.sh
dotnet-version = 8.0
dotnet-root    = $(devenv)opt/dotnet-$(dotnet-version)/
dotnet-bin     = $(bindir)dotnet

ifeq ($(CFG_DOTNET),local)
DOTNET_ROOT = $(patsubst %/,%,$(curdir)$(dotnet-root))
export DOTNET_ROOT
endif

target-cachedir = $(cachedir).exists
target-devenv = $(devenv).exists
target-bindir = $(bindir).exists
target-sm = $(devenv).sm-init
target-plugin = $(devenv).plugin-build

csharp-ls-bin = $(bindir)csharp-ls
csharp-ls-src = lsp/csharp-language-server/src/CSharpLanguageServer/
csharp-ls-dst = $(devenv)opt/csharp-ls/
csharp-ls-dep = $(wildcard $(csharp-ls-src)*.fs)

clangd-github-repo = "clangd/clangd"
clangd-url-file = $(devenv)clangd-url
clangd-url = $(file <$(clangd-url-file))
clangd-bin = $(bindir)clangd
clangd-unpack-dst = $(devenv)opt/
clangd-dst = $(firstword $(wildcard $(clangd-unpack-dst)*/bin/clangd))

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
	$(SHELL) "$<" --install-dir "$(dotnet-root)" --channel $(dotnet-version)
	$(call link-bin,$(dotnet-root)dotnet)
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

.PHONY: plugin
plugin: $(target-plugin)

ifeq ($(CFG_CSHARP_LS),local)
$(csharp-ls-bin): $(csharp-ls-dep) $(dotnet-bin) $(target-sm)
	$(DOTNET) build -c Release -r linux-x64 --self-contained=false -o "$(csharp-ls-dst)" "$(csharp-ls-src)"
	$(call link-bin,$(csharp-ls-dst)CSharpLanguageServer,csharp-ls)
	$(TOUCH) "$@"
else
$(csharp-ls-bin): $(target-bindir)
	$(call link-native-bin,csharp-ls)
endif

ifeq ($(CFG_CLANGD),local)
$(clangd-url-file): $(target-devenv)
	$(PYTHON) "$(github-assets)" -r "$(clangd-github-repo)" -f "clangd-linux-[0-9.]+\.zip" > "$@"

$(clangd-bin): $(clangd-url-file) $(target-cachedir)
	$(MKDIR) "$(clangd-unpack-dst)"
	$(WGET) "$(clangd-url)" -O "$(cachedir)$(notdir $(clangd-url))"
	( cd "$(clangd-unpack-dst)" && $(UNZIP) -o "$(curdir)$(cachedir)$(notdir $(clangd-url))" )
	$(call link-bin,$(clangd-dst),clangd)
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
	$(file >>$@,let $$PATH = '$(new-path):' . $$PATH)
else
	$(file >$@,let $$PATH = '$(new-path):' . $$PATH)
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
$(ECHO) 'if filereadable("$(curdir)vimrc")' >> "$1"
$(ECHO) '    exe "source " . fnameescape("$(curdir)vimrc")' >> "$1"
$(ECHO) 'endif' >> "$1"
$(ECHO) '" endvimdevpack' >> "$1"
endef

.PHONY: install-vim
install-vim: all
	$(MKDIR) cache/undo
	$(call patch-vimrc,$(HOME)/.vimrc)

.PHONY: install-nvim
install-nvim: all
	$(MKDIR) cache/undo-nvim
	$(MKDIR) $(HOME)/.config/nvim
	$(call patch-vimrc,$(HOME)/.config/nvim/init.vim)

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

