ECHO  = echo
GIT   = git
LN    = ln
MKDIR = mkdir -p

mkpath = $(realpath $(lastword $(MAKEFILE_LIST)))
curdir = $(dir $(mkpath))

dst = $(HOME)/.vim/pack/vimdevpack

.PHONY: sm
sm:
	$(GIT) submodule update --init --recursive 

.PHONY: install-ln
install-ln: sm
	$(MKDIR) $(HOME)/.vim/pack/vimdevpack/cache/undo
	$(RM) "$(dst)"
	$(LN) -sf "$(curdir)" "$(dst)"
	$(ECHO) 'if filereadable("$(dst)/vimrc") | source $(dst)/vimrc | endif' \
		>> "$(HOME)/.vimrc"
