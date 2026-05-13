$(call fake,dotnet)

ifeq ($(CFG_DOTNET_NATIVE),)
DOTNET_ROOT = $(DEVENV)/dotnet
export DOTNET_ROOT

$(call vimenv-addvar,$$DOTNET_ROOT,$(call winpath,$(abspath $(DOTNET_ROOT))))

ifeq ($(OS),Windows_NT)
$(DL)/dotnet-install.ps1: $(DL)/.exists
	$(call wget,https://dot.net/v1/dotnet-install.ps1,$@)

$(DOTNET_ROOT)/dotnet: $(DOTNET_ROOT)/.exists
$(DOTNET_ROOT)/dotnet: $(DL)/dotnet-install.ps1
	$(foreach sdk,$(CFG_DOTNET_SDKS),\
		powershell "$<" -InstallDir "$(dir $@)" -Channel "$(sdk)"$(NL)\
	)
else
$(DL)/dotnet-install.sh: $(DL)/.exists
	$(call wget,https://dot.net/v1/dotnet-install.sh,$@)

$(DOTNET_ROOT)/dotnet: $(DOTNET_ROOT)/.exists
$(DOTNET_ROOT)/dotnet: $(DL)/dotnet-install.sh
	$(foreach sdk,$(CFG_DOTNET_SDKS),\
		$(SHELL) "$<" --install-dir "$(dir $@)" --channel "$(sdk)"$(NL)\
	)
endif

$(call linkbin,$(DOTNET_ROOT)/dotnet)

dotnet: $(BIN)/dotnet
endif

DOTNET_TOOLSDIR = $(DEVENV)/dotnet-tools

define dotnet-tool-target=
$$(DOTNET_TOOLSDIR)/$1: $$(fake-dotnet) $$(DOTNET_TOOLSDIR)/.exists
	dotnet tool update -v d $2 --tool-path "$$(dir $$@)"

$(call linkbin,$(DOTNET_TOOLSDIR)/$1)
endef

dotnet-tool = $(eval $(call dotnet-tool-target,$1,$(if $2,$2,$1)))
