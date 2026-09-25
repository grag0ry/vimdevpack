.PHONY: clean-dotnet update-dotnet
ifeq ($(CFG_DOTNET_NATIVE),)
DOTNET_ROOT = $(CFG_PATH_DEVENV)/dotnet
export DOTNET_ROOT

$(call vimenv-addvar,$$DOTNET_ROOT,$(call winpath,$(abspath $(DOTNET_ROOT))))

ifeq ($(OS),Windows_NT)
$(call dl,https://dot.net/v1/dotnet-install.ps1)
DOTNET_INSTALL = dotnet-install.ps1
dotnet-install-sdk-impl = powershell "$(CFG_PATH_DL)/$(DOTNET_INSTALL)" \
	-InstallDir "$(DOTNET_ROOT)" \
	-Channel "$1"
else
$(call dl,https://dot.net/v1/dotnet-install.sh)
DOTNET_INSTALL = dotnet-install.sh
dotnet-install-sdk-impl = $(SHELL) "$(CFG_PATH_DL)/$(DOTNET_INSTALL)" \
	--install-dir "$(DOTNET_ROOT)" \
	--channel "$1"
endif
dotnet-install-sdk = $(call lock,$(call dotnet-install-sdk-impl,$1),dotnet)

$(call fake,dotnet-sdk-%,$(CFG_PATH_DL)/$(DOTNET_INSTALL))
dotnet-sdk-%: $(CFG_PATH_DL)/$(DOTNET_INSTALL)
	$(call dotnet-install-sdk,$*)

.PHONY: update-dotnet-sdk-%
update-dotnet-sdk-%: update-dl-$(DOTNET_INSTALL)
	$(call dotnet-install-sdk,$*)

$(DOTNET_ROOT)/dotnet: $(call fake-target,$(CFG_DOTNET_SDKS:%=dotnet-sdk-%))
$(call linkbin,$(DOTNET_ROOT)/dotnet)
update-bin-dotnet: $(CFG_DOTNET_SDKS:%=update-dotnet-sdk-%)

$(call fake,dotnet,$(BIN)/dotnet)
update-dotnet: update-bin-dotnet
clean-dotnet: clean-bin-dotnet
	rm -rf "$(CFG_PATH_DEVENV)/dotnet" \
		$(call fake-target,dotnet-sdk-*) \
		"$(fake-dotnet)"
else
$(call fake,dotnet)
clean-dotnet:
	rm -f "$(fake-dotnet)"

endif

DOTNET_TOOL_DIR = $(CFG_PATH_DEVENV)/dotnet-tool

.PHONY: clean-dotnet-tool
clean-dotnet-tool:
	rm -rf "$(DOTNET_TOOL_DIR)" \
		$(call fake-target,dotnet-tool-*)

define dotnet-tool-impl-bin =

$$(DOTNET_TOOL_DIR)/$2: $$(fake-dotnet-tool-$1)
$$(call linkbin,$$(DOTNET_TOOL_DIR)/$2)
update-bin-$2: update-dotnet-tool-$1
clean-dotnet-tool: clean-bin-$2
endef

define dotnet-tool-impl =
$$(call fake,dotnet-tool-$1,$$(fake-dotnet))
dotnet-tool-$1:
	$$(call lock,dotnet tool install "$1" --tool-path "$$(DOTNET_TOOL_DIR)")

.PHONY: update-dotnet-tool-$1
update-dotnet-tool-$1: update-dotnet
	$$(call lock,dotnet tool update "$1" --tool-path "$$(DOTNET_TOOL_DIR)")

$(foreach b,$2,$(call dotnet-tool-impl-bin,$1,$b))
endef

dotnet-tool = $(eval $(call dotnet-tool-impl,$1,$(if $2,$2,$1)))
