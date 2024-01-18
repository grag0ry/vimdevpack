ECHO   = echo
GIT    = git
LN     = ln -sf
MKDIR  = mkdir -p
WGET   = wget
SED    = sed
TOUCH  = touch
DOTNET = $(dotnet-bin)

mkpath     = $(realpath $(lastword $(MAKEFILE_LIST)))
curdir     = $(dir $(mkpath))
cachedir   = cache/
devenv     = devenv/
tools      = tools/
bindir     = $(devenv)bin/
link-bin   = $(LN) "../../$1" "$(bindir)$(if $2,$2,$(notdir $1))"
plugin-git = plugin.git/
plugin-dir = plugin.d/
new-path += $(patsubst %/,%,$(curdir)$(bindir))

dotnet-websrc  = https://dot.net/v1/dotnet-install.sh
dotnet-install = $(devenv)dotnet-install.sh
dotnet-version = 8.0
dotnet-root    = $(devenv)opt/dotnet-$(dotnet-version)/
dotnet-bin     = $(bindir)dotnet

DOTNET_ROOT = $(patsubst %/,%,$(curdir)$(dotnet-root))
export DOTNET_ROOT

target-cachedir = $(cachedir).exists
target-devenv = $(devenv).exists
target-bindir = $(bindir).exists
target-sm = $(devenv).sm-init
target-plugin = $(devenv).plugin-build

csharp-ls-bin = $(bindir)csharp-ls
csharp-ls-src = lsp/csharp-language-server/src/CSharpLanguageServer/
csharp-ls-dst = $(devenv)opt/csharp-ls/
csharp-ls-dep = $(wildcard $(csharp-ls-src)*.fs)

devenv-enviroment-vim = $(devenv)env.vim
devenv-enviroment-sh  = $(devenv)env.sh

gtags-websrc = https://cvs.savannah.gnu.org/viewvc/*checkout*/global/global/gtags.vim
gtags-dst = $(plugin-dir)gtags/plugin/gtags.vim

git-upgrade = $(tools)git-upgrade.sh

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

$(dotnet-install): $(target-devenv)
	$(WGET) "$(dotnet-websrc)" -O "$@"
	$(TOUCH) "$@"

$(dotnet-bin): $(dotnet-install) $(target-bindir)
	$(SHELL) "$<" --install-dir "$(dotnet-root)" --channel $(dotnet-version)
	$(call link-bin,$(dotnet-root)dotnet)
	$(TOUCH) "$@"

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

$(csharp-ls-bin): $(csharp-ls-dep) $(dotnet-bin) $(target-sm)
	$(DOTNET) build -c Release -r linux-x64 --self-contained=false -o "$(csharp-ls-dst)" "$(csharp-ls-src)"
	$(call link-bin,$(csharp-ls-dst)CSharpLanguageServer,csharp-ls)
	$(TOUCH) "$@"

.PHONY: lsp
lsp: $(csharp-ls-bin)

$(devenv-enviroment-vim): $(target-devenv)
	$(file >$@,let $$DOTNET_ROOT = '$(DOTNET_ROOT)')
	$(file >>$@,let $$PATH = '$(new-path):' . $$PATH)

$(devenv-enviroment-sh): $(target-devenv)
	$(file >$@,export $$DOTNET_ROOT = '$(DOTNET_ROOT)')
	$(file >>$@,export $$PATH = "$(new-path):$$PATH")

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
