$(call fake,dotnet)

ifeq ($(CFG_DOTNET_NATIVE),)
DOTNET_ROOT = $(DEVENV)/dotnet-$(CFG_DOTNET_VERSION)
export DOTNET_ROOT

define VIMENV +=
$(NL)let $$DOTNET_ROOT = '$(call winpath,$(abspath $(DOTNET_ROOT)))'
endef

CLEAN += $(CACHE)/dotnet-install.sh

ifeq ($(OS),Windows_NT)
$(CACHE)/dotnet-install.ps1: $(CACHE)/.exists
	$(call wget,https://dot.net/v1/dotnet-install.ps1,$@)

$(DOTNET_ROOT)/dotnet: $(DOTNET_ROOT)/.exists
$(DOTNET_ROOT)/dotnet: $(CACHE)/dotnet-install.ps1
	powershell "$<" -InstallDir "$(dir $@)" -Channel "$(CFG_DOTNET_VERSION)"
else
$(CACHE)/dotnet-install.sh: $(CACHE)/.exists
	$(call wget,https://dot.net/v1/dotnet-install.sh,$@)

$(DOTNET_ROOT)/dotnet: $(DOTNET_ROOT)/.exists
$(DOTNET_ROOT)/dotnet: $(CACHE)/dotnet-install.sh
	$(SHELL) "$<" --install-dir "$(dir $@)" --channel "$(CFG_DOTNET_VERSION)"
endif

$(call linkbin,$(DOTNET_ROOT)/dotnet)

dotnet: $(BIN)/dotnet
endif

DOTNET_TOOLSDIR = $(DEVENV)/dotnet-tools-$(CFG_DOTNET_VERSION)

define dotnet-tool-target=
$$(DOTNET_TOOLSDIR)/$1: $$(fake-dotnet) $$(DOTNET_TOOLSDIR)/.exists
	dotnet tool update -v d $2 --tool-path "$$(dir $$@)"

$(call linkbin,$(DOTNET_TOOLSDIR)/$1)
endef

dotnet-tool = $(eval $(call dotnet-tool-target,$1,$(if $2,$2,$1)))
