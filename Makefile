ECHO  = echo
GIT   = git
LN    = ln
MKDIR = mkdir -p
WGET  = wget

mkpath = $(realpath $(lastword $(MAKEFILE_LIST)))
curdir = $(dir $(mkpath))
dst    = $(HOME)/.vim/pack/vimdevpack
sm     = $(wildcard .sm/*)
sm-branch = master

gtags_src = https://cvs.savannah.gnu.org/viewvc/*checkout*/global/global/gtags.vim
gtags_dst = start/gtags/plugin/gtags.vim

.PHONY: all
all: sm

# gen submodule update rule
define sm_upgrade_gen_one =
$2 += $(notdir $1)-upgrade

.PHONY: $(notdir $1)-upgrade
$(notdir $1)-upgrade:
	( cd $1 && $(GIT) checkout $$(sm-branch) && $$(GIT) pull )

endef
sm_upgrade_gen = $(foreach a,$1,$(call sm_upgrade_gen_one,$a,$2))
sm_upgrade = $(eval $(call sm_upgrade_gen,$1,$2))

$(call sm_upgrade,$(sm),sm_upgrade_targets)

gnuplot.vim-upgrade: sm-branch=main

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

.PHONY: omnisharp-net6
omnisharp-net6:
	start/omnisharp-vim/installer/omnisharp-manager.sh -6 -l cache/omnisharp/net6

.PHONY: omnisharp-wsl
omnisharp-wsl:
	start/omnisharp-vim/installer/omnisharp-manager.sh -W -l cache/omnisharp/wsl

.PHONY: install-ln
install-ln: sm
	$(RM) "$(dst)"
	$(MKDIR) $(HOME)/.vim/pack/
	$(LN) -sf "$(curdir)" "$(dst)"
	$(MKDIR) cache/undo
	$(ECHO) 'if filereadable("$(dst)/vimrc") | source $(dst)/vimrc | endif' \
		>> "$(HOME)/.vimrc"
