PRJROOT = $(dir $(lastword $(MAKEFILE_LIST)))
TOOLS = $(PRJROOT)tools/
CONFIG = $(PRJROOT)config.mk

ifeq ($(OS),Windows_NT)
MSYS = winsymlinks:native
export MSYS
winpath = $(shell cygpath -w "$1")
linpath = $(shell cygpath -u "$1")
pathsep = ;
NVIM_CONFIG = $(call linpath,$(LOCALAPPDATA))/nvim/init.vim
else
winpath = $1
linpath = $1
pathsep = :
NVIM_CONFIG = $(HOME)/.config/nvim/init.vim
endif

-include $(CONFIG)

.PHONY: config
config:
	$(TOOLS)makeconf.sh > "$(CONFIG)"

.PHONY: print-config
print-config:
	@cat "$(CONFIG)"

$(foreach v,$(filter CFG_%, $(.VARIABLES)),$(eval config: export $v=$($v)))
$(foreach v,$(filter CFG_%, $(.VARIABLES)),$(eval print-config: export $v=$($v)))

define NL=


endef

M4=m4 -P $(foreach v,$(filter CFG_%, $(.VARIABLES)),$(if $($v),-D"m4_$(v)=$($(v))"))

BIN    = $(CFG_BINDIR)
CACHE  = $(CFG_CACHE)
DEVENV = $(CFG_DEVENV)
VIMENV =

CLEAN = $(BIN) $(DEVENV)

export PATH:=$(abspath $(BIN)):$(PATH)

define VIMENV =
let g:PackPath = '$(call winpath,$(abspath $(PRJROOT)))'
let g:PackDevenvPath = '$(call winpath,$(abspath $(DEVENV)))'
let g:PackCachePath = '$(call winpath,$(abspath $(CACHE)))'
endef

define VIMENV +=
$(NL)let $$PATH = '$(call winpath,$(abspath $(BIN)))$(pathsep)' . $$PATH
endef

%/.exists:
	mkdir -p "$(dir $@)"
	touch "$@"

define fake-target =
.PHONY: $1
fake-$1 = $$(DEVENV)/.fake-$1
$$(fake-$1): $$(DEVENV)/.exists
	$$(MAKE) -f $$(firstword $$(MAKEFILE_LIST)) $1
	touch "$$@"

endef

ifeq ($(OS),Windows_NT)
define linkbin-target =
$1: $(BIN)/.exists
$$(BIN)/$2: $(BIN)/.exists
$$(BIN)/$2: $1
	printf "%s\n" \
		"@echo off" \
		'call "$$(call winpath,$$(abspath $$<))" %*' \
	> "$$@.bat"
	ln -fs "$$(abspath $$<)" "$$@"
	touch "$$@"

endef
else
define linkbin-target =
$1: $(BIN)/.exists
$$(BIN)/$2: $(BIN)/.exists
$$(BIN)/$2: $1
	ln -fs "$$(abspath $$<)" "$$@"

endef
endif

fake = $(eval $(call fake-target,$1))
linkbin = $(eval $(call linkbin-target,$1,$(if $2,$2,$(notdir $1))))
wget = wget --progress=dot:giga "$1" -O "$2" --no-use-server-timestamps
github-assets = set -o pipefail && $(TOOLS)github-assets.sh "$1" \
	| grep -m1 "$(if $3,$3,.*)" \
	| xargs -r -i $(call wget,{},$2)
