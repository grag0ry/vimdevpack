BIN = $(CFG_PATH_DEVENV)/bin
TOOLS = tools
FAKE_TARGET_DIR = .fake-target
LOCK_DIR = .lock

ifeq ($(OS),Windows_NT)
export MSYS := winsymlinks:native
NVIM_CONFIG = $(call linpath,$(LOCALAPPDATA))/nvim/init.vim
winpath = $(shell cygpath -w "$1")
linpath = $(shell cygpath -u "$1")
pathsep = ;
else
NVIM_CONFIG = $(HOME)/.config/nvim/init.vim
winpath = $1
linpath = $1
pathsep = :
endif

define NL=


endef

include config.mk
$(foreach v,$(filter CFG_%, $(.VARIABLES)),$(eval config.mk: export $v=$($v)))
config.mk: $(TOOLS)/makeconf.sh | $(FAKE_TARGET_DIR)/.exists $(LOCK_DIR)/.exists
	$< > $@

export PATH := $(abspath $(BIN)):$(PATH)

VIMENV = " This file is auto generate by `make vim.env` \
	$(NL)" vim: filetype=vim

define vimenv-add-impl =
$(eval define VIMENV +=
$(NL)$1
endef)
endef
vimenv-add = $(call vimenv-add-impl,$(subst $$,$$$$,$1))
vimenv-addvar = $(call vimenv-add,let $1 = '$2')
vimenv-addvar-path = $(call vimenv-addvar,$1,$(call winpath,$(abspath $2)))

$(foreach v,$(filter CFG_%, $(.VARIABLES)),$(call vimenv-addvar,g:VDP_$v,$($v)))
$(call vimenv-add,let $$PATH = '$(call winpath,$(abspath $(BIN)))$(pathsep)' . $$PATH)

vim.env: config.mk
	@echo "Writing $@"
	$(file >$@,$(VIMENV))
	sed -i -e 's/\s*$$//' "$@"

%/.exists:
	mkdir -p "$(dir $@)"
	touch "$@"

define fake-impl =
.PHONY: $1
ifneq ($(strip $2),)
ifeq ($(findstring %,$1),)
$1: $2
endif
endif
fake-$1 = $$(FAKE_TARGET_DIR)/fake-$1
$$(FAKE_TARGET_DIR)/fake-$1: $2
	$$(MAKE) -f $$(firstword $$(MAKEFILE_LIST)) $$(@:$$(FAKE_TARGET_DIR)/fake-%=%)
	touch "$$@" $(if $3,-r "$3",)
endef
fake = $(eval $(call fake-impl,$1,$2,$3))
fake-target = $(1:%=$(FAKE_TARGET_DIR)/fake-%)
touch-fake = touch "$(fake-$@)"
.PHONY: clean-fake
clean-fake:
	rm -rf "$(FAKE_TARGET_DIR)"

ifeq ($(OS),Windows_NT)
define linkbin-target =
$$(BIN)/$2: | $$(BIN)/.exists
$$(BIN)/$2: $1
	printf "%s\n" \
		"@echo off" \
		'call "$$(call winpath,$$(abspath $$<))" %*' \
	> "$$@.bat"
	ln -nfs "$$(abspath $$<)" "$$@"
	touch "$$@"

.PHONY: clean-bin-$2
clean-bin-$2:
	rm -f "$$(BIN)/$2" "$$(BIN)/$2.bat"

.PHONY: update-bin-$2
update-bin-$2:
	$(MAKE) $$(BIN)/$2
endef
else
define linkbin-impl =
$$(BIN)/$2: | $$(BIN)/.exists
$$(BIN)/$2: $1
	ln -nfs "$$(abspath $$<)" "$$@"
	touch "$$@"

.PHONY: clean-bin-$2
clean-bin-$2:
	rm -f "$$(BIN)/$2"

.PHONY: update-bin-$2
update-bin-$2:
	$(MAKE) $$(BIN)/$2
endef
endif
linkbin = $(eval $(call linkbin-impl,$1,$(if $2,$2,$(notdir $1))))

.PHONY: clean-lock
clean-lock:
	rm -rf "$(LOCK_DIR)"
lock = flock -x "$(LOCK_DIR)/$(if $2,$2,$@)" $1

wget = wget --progress=dot:giga "$1" -O "$2" -N
fetch-newer = "$(TOOLS)/fetch-newer.sh" "$1" "$2"
github-assets = set -o pipefail && $(TOOLS)/github-assets.sh "$1" \
	| grep -m1 "$(if $3,$3,.*)" \
	| xargs -r -i $(call fetch-newer,{},$2)

define dl-impl =
.PHONY: update-dl-$2
update-dl-$2 $$(CFG_PATH_DL)/$2: | $$(CFG_PATH_DL)/.exists
	$(if $3,$$(call github-assets,$1,$$(CFG_PATH_DL)/$2,$3),$$(call fetch-newer,$1,$$(CFG_PATH_DL)/$2))
endef

dl = $(eval $(call dl-impl,$1,$(or $2,$(notdir $1))))
dl-github = $(eval $(call dl-impl,$1,$(or $2,$(notdir $1)),$(or $3,.*)))

define arc-impl =
$$(call fake,arc-$(notdir $1),$1,$1)
arc-$(notdir $1):
	"$$(TOOLS)/extract.sh" "$1" "$2" $(if $3,$3,)

.PHONY: update-arc-$(notdir $1)
update-arc-$(notdir $1):
	$$(MAKE) $$(fake-arc-$(notdir $1))

.PHONY: clean-arc-$(notdir $1)
clean-arc-$(notdir $1):
	rm -rf "$2" \
		"$$(fake-arc-$(notdir $1))"

endef
arc = $(eval $(call arc-impl,$1,$2,$3))

define side-effects-impl
$2: $1
	test -f "$$@"
endef
side-effects = $(eval $(call side-effects-impl,$1,$2))
