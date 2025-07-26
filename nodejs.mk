$(call fake,nodejs)

ifeq ($(CFG_NODEJS_NATIVE),)
CLEAN += $(CACHE)/fnm-install.sh
$(CACHE)/fnm-install.sh: $(CACHE)/.exists
	$(call wget,https://fnm.vercel.app/install,$@)

$(DEVENV)/fnm/fnm: $(CACHE)/fnm-install.sh
	mkdir -p "$(dir $@)"
	$(SHELL) "$<" -s -d "$(dir $@)"
	touch "$@"

$(call linkbin,$(DEVENV)/fnm/fnm)

$(call fake,nodejs-install)
nodejs-install: $(BIN)/fnm
	fnm --fnm-dir="$(abspath $(DEVENV)/fnm)" install --lts

ifeq ($(OS),Windows_NT)
nodejs-bindir = $(DEVENV)/fnm/aliases/lts-latest
else
nodejs-bindir = $(DEVENV)/fnm/aliases/lts-latest/bin
endif

$(nodejs-bindir)/%: $(fake-nodejs-install)
	touch "$@"

$(call linkbin,$(nodejs-bindir)/node)
$(call linkbin,$(nodejs-bindir)/npm)
$(call linkbin,$(nodejs-bindir)/npx)

nodejs: $(BIN)/node $(BIN)/npm $(BIN)/npx
endif

NODEJS_NPMDIR = $(DEVENV)/npm
NODEJS_NPMDIR_BIN = $(NODEJS_NPMDIR)/node_modules/.bin

define nodejs-npm-target=
$$(NODEJS_NPMDIR_BIN)/$1: $$(fake-nodejs) $$(NODEJS_NPMDIR_BIN)/.exists
	npm -d install --prefix "$$(NODEJS_NPMDIR)" "$2"

$(call linkbin,$(NODEJS_NPMDIR_BIN)/$1)
endef

nodejs-npm = $(eval $(call nodejs-npm-target,$1,$(if $2,$2,$1)))
