ECHO  = echo
GIT   = git
LN    = ln
MKDIR = mkdir -p
WGET  = wget
SED   = sed
TOUCH = touch

mkpath  = $(realpath $(lastword $(MAKEFILE_LIST)))
curdir  = $(dir $(mkpath))
packdir = $(curdir)vimpack
dst-vim = $(HOME)/.vim/pack/vimdevpack
sm      = $(wildcard .sm/*)
sm-branch = master

gtags_src = https://cvs.savannah.gnu.org/viewvc/*checkout*/global/global/gtags.vim
gtags_dst = plugin.vim/gtags/plugin/gtags.vim


define patch-vimrc =
$(TOUCH) "$1"
$(SED) -i -e '/vimdevpack/{:a;N;/endvimdevpack/!ba};/vimdevpack/d' "$1"
$(ECHO) '" vimdevpack' >> "$1"
$(ECHO) 'if filereadable("$(curdir)vimrc")' >> "$1"
$(ECHO) '    exe "source " . fnameescape("$(curdir)vimrc")' >> "$1"
$(ECHO) 'endif' >> "$1"
$(ECHO) '" endvimdevpack' >> "$1"
endef

.PHONY: all
all: sm

# gen submodule update rule
define sm_upgrade_gen_one =
$2 += $(notdir $1)-upgrade

.PHONY: $(notdir $1)-upgrade
$(notdir $1)-upgrade:
	( cd $1 \
		&& $$(GIT) reset . \
		&& $$(GIT) checkout . \
		&& $$(GIT) checkout $$(sm-branch) \
		&& $$(GIT) checkout . \
		&& $$(GIT) reset --hard origin/HEAD \
		&& $$(GIT) clean -fdx \
		&& $$(GIT) pull )
ifeq ($(notdir $1),telescope-fzf-native.nvim)
	$$(MAKE) -C $1
endif

endef
sm_upgrade_gen = $(foreach a,$1,$(call sm_upgrade_gen_one,$a,$2))
sm_upgrade = $(eval $(call sm_upgrade_gen,$1,$2))

$(call sm_upgrade,$(sm),sm_upgrade_targets)

gnuplot.vim-upgrade: sm-branch=main

telescope-fzf-native.nvim-upgrade: sm-branch=main

neo-tree.nvim-upgrade: sm-branch=main

nui.nvim-upgrade: sm-branch=main

.PHONY: sm
sm:
	$(GIT) submodule update --init --recursive

.PHONY: sm-upgrade
sm-upgrade: $(sm_upgrade_targets)

.PHONY: gtags-upgrade
gtags-upgrade:
	$(WGET) "$(gtags_src)" -O "$(gtags_dst)"

.PHONY: upgrade
upgrade: sm-upgrade gtags-upgrade
	@$(ECHO) Successfully upgraded

.PHONY: install-vim
install-vim: sm
	$(RM) "$(dst-vim)"
	$(MKDIR) "$(dir dst-vim)"
	$(LN) -s "$(packdir)" "$(dst-vim)"
	$(MKDIR) cache/undo
	$(call patch-vimrc,$(HOME)/.vimrc)

.PHONY: install-nvim
install-nvim: sm
	$(MKDIR) cache/undo-nvim
	$(MKDIR) $(HOME)/.config/nvim
	$(call patch-vimrc,$(HOME)/.config/nvim/init.vim)
