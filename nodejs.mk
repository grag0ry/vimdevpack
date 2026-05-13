$(call fake,nodejs)

ifeq ($(CFG_NODEJS_NATIVE),)
$(DL)/fnm-install.sh: $(DL)/.exists
	$(call wget,https://fnm.vercel.app/install,$@)

$(DEVENV)/fnm/fnm: $(DL)/fnm-install.sh
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

$(call fake,nodejs-audit-fix)
nodejs-audit-fix:
	jq '.overrides.minimatch = "^10.2.3"' "$(NODEJS_NPMDIR)/package.json" > "$(NODEJS_NPMDIR)/package.json.tmp"
	mv "$(NODEJS_NPMDIR)/package.json.tmp" "$(NODEJS_NPMDIR)/package.json"
	npm -d audit fix --prefix "$(NODEJS_NPMDIR)"

define nodejs-npm-target=
$$(NODEJS_NPMDIR_BIN)/$1: $$(fake-nodejs) $$(NODEJS_NPMDIR_BIN)/.exists
	npm -d install --prefix "$$(NODEJS_NPMDIR)" "$2"

nodejs-audit-fix: $$(NODEJS_NPMDIR_BIN)/$1
$$(BIN)/$1: $$(fake-nodejs-audit-fix)
$$(call linkbin,$$(NODEJS_NPMDIR_BIN)/$1)

endef

nodejs-npm = $(eval $(call nodejs-npm-target,$1,$(if $2,$2,$1)))
