UV_DIRECTORY = $(DEVENV)/uv
UV_CACHE_DIR = $(UV_DIRECTORY)/cache
UV_TOOL_DIR = $(UV_DIRECTORY)/tools
UV_TOOL_BIN_DIR = $(BIN)
UV_PYTHON_INSTALL_DIR = $(UV_DIRECTORY)/python
UV_PYTHON_BIN_DIR = $(BIN)

$(call cargo-install,uv)

define uv-tool-impl =

$$(BIN)/$1: export UV_DIRECTORY := $$(abspath $$(UV_DIRECTORY))
$$(BIN)/$1: export UV_CACHE_DIR := $$(abspath $$(UV_CACHE_DIR))
$$(BIN)/$1: export UV_TOOL_DIR := $$(abspath $$(UV_TOOL_DIR))
$$(BIN)/$1: export UV_TOOL_BIN_DIR := $$(abspath $$(UV_TOOL_BIN_DIR))
$$(BIN)/$1: export UV_PYTHON_INSTALL_DIR := $$(abspath $$(UV_PYTHON_INSTALL_DIR))
$$(BIN)/$1: export UV_PYTHON_BIN_DIR := $$(abspath $$(UV_PYTHON_BIN_DIR))

$$(BIN)/$1: $$(BIN)/uv
	uv tool install --reinstall "$2"

endef
uv-tool = $(eval $(call uv-tool-impl,$1,$(if $2,$2,$1)))
