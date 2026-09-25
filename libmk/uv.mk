UV_DIRECTORY = $(CFG_PATH_DEVENV)/uv
UV_CACHE_DIR = $(CFG_PATH_DL)/uv
UV_TOOL_DIR = $(UV_DIRECTORY)/tools
UV_TOOL_BIN_DIR = $(UV_DIRECTORY)/bin
UV_PYTHON_INSTALL_DIR = $(UV_DIRECTORY)/python
UV_PYTHON_BIN_DIR = $(UV_DIRECTORY)/bin

define uv-export-impl =
$1: export UV_DIRECTORY := $$(abspath $$(UV_DIRECTORY))
$1: export UV_CACHE_DIR := $$(abspath $$(UV_CACHE_DIR))
$1: export UV_TOOL_DIR := $$(abspath $$(UV_TOOL_DIR))
$1: export UV_TOOL_BIN_DIR := $$(abspath $$(UV_TOOL_BIN_DIR))
$1: export UV_PYTHON_INSTALL_DIR := $$(abspath $$(UV_PYTHON_INSTALL_DIR))
$1: export UV_PYTHON_BIN_DIR := $$(abspath $$(UV_PYTHON_BIN_DIR))
$1: export PATH := $$(abspath $$(UV_TOOL_BIN_DIR)):$$(PATH)
endef
uv-export = $(eval $(call uv-export-impl,$1))

ifeq ($(OS),Windows_NT)
UV_ARC = uv-x86_64-pc-windows-msvc.zip
$(call dl-github,astral-sh/uv,$(UV_ARC),$(UV_ARC))
$(call arc,$(CFG_PATH_DL)/$(UV_ARC),$(UV_DIRECTORY)/$(UV_ARC),0)
else
UV_ARC = uv-x86_64-unknown-linux-gnu.tar.gz
$(call dl-github,astral-sh/uv,$(UV_ARC),$(UV_ARC))
$(call arc,$(CFG_PATH_DL)/$(UV_ARC),$(UV_DIRECTORY)/$(UV_ARC),1)
endif
$(call side-effects,$(fake-arc-$(UV_ARC)),$(UV_DIRECTORY)/$(UV_ARC)/uv)
$(call linkbin,$(UV_DIRECTORY)/$(UV_ARC)/uv)
update-arc-$(UV_ARC): update-dl-$(UV_ARC)
update-bin-uv: update-arc-$(UV_ARC)

.PHONY: clean-uv
clean-uv: clean-bin-uv clean-arc-$(UV_ARC)
	rm -rf "$(UV_DIRECTORY)" \
		$(call fake-target,uv-*)

define uv-tool-impl-bin =

$$(UV_TOOL_BIN_DIR)/$2: $$(fake-uv-$1)
$$(call linkbin,$$(UV_TOOL_BIN_DIR)/$2)
update-bin-$2: update-uv-$1
clean-uv: clean-bin-$2
endef

define uv-tool-impl =
$$(call fake,uv-$1,$$(BIN)/uv)
$(call uv-export-impl,uv-$1)
uv-$1:
	MAKEFLAGS= uv tool install "$1"

.PHONY: update-uv-$1
$(call uv-export-impl,update-uv-$1)
update-uv-$1: update-bin-uv
	MAKEFLAGS= uv tool install -U "$1"

$(foreach b,$2,$(call uv-tool-impl-bin,$1,$b))
endef
uv-tool = $(eval $(call uv-tool-impl,$1,$(if $2,$2,$1)))
