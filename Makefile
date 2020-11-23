ECHO  = echo
GIT   = git
LN    = ln
MKDIR = mkdir -p
WGET  = wget

mkpath = $(realpath $(lastword $(MAKEFILE_LIST)))
curdir = $(dir $(mkpath))
dst    = $(HOME)/.vim/pack/vimdevpack
sm     = $(wildcard .sm/*)

gtags_src = https://cvs.savannah.gnu.org/viewvc/*checkout*/global/global/gtags.vim
gtags_dst = start/gtags/plugin/gtags.vim

# gen submodule update rule
define sm_upgrade_gen_one =
$2 += $(notdir $1)-upgrade

.PHONY: $(notdir $1)-upgrade
$(notdir $1)-upgrade:
	( cd $1 && $$(GIT) pull )

endef
sm_upgrade_gen = $(foreach a,$1,$(call sm_upgrade_gen_one,$a,$2))
sm_upgrade = $(eval $(call sm_upgrade_gen,$1,$2))

$(call sm_upgrade,$(sm),sm_upgrade_targets)

.PHONY: all
all: sm

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

.PHONY: install-ln
install-ln: sm
	$(MKDIR) $(HOME)/.vim/pack/vimdevpack/cache/undo
	$(RM) "$(dst)"
	$(LN) -sf "$(curdir)" "$(dst)"
	$(ECHO) 'if filereadable("$(dst)/vimrc") | source $(dst)/vimrc | endif' \
		>> "$(HOME)/.vimrc"
