.PHONY: nodejs clean-nodejs update-nodejs

$(DL)/fnm-install.sh: | $(DL)/.exists
	$(call wget,https://fnm.vercel.app/install,$@)

$(DEVENV)/fnm/fnm: $(DL)/fnm-install.sh
	mkdir -p "$(dir $@)"
	$(SHELL) "$<" -s -d "$(dir $@)"
	touch "$@"

$(call fake,install-nodejs,$(DEVENV)/fnm/fnm)
install-nodejs: $(DEVENV)/fnm/fnm
	"$(DEVENV)/fnm/fnm" --fnm-dir="$(abspath $(DEVENV)/fnm)" install --lts

ifeq ($(OS),Windows_NT)
NODEJS_BINDIR = $(DEVENV)/fnm/aliases/lts-latest
else
NODEJS_BINDIR = $(DEVENV)/fnm/aliases/lts-latest/bin
endif

$(NODEJS_BINDIR)/%: $(fake-install-nodejs)
	touch "$@"

$(call linkbin,$(NODEJS_BINDIR)/node)
$(call linkbin,$(NODEJS_BINDIR)/npm)
$(call linkbin,$(NODEJS_BINDIR)/npx)

ifeq ($(CFG_NODEJS_NATIVE),)
$(call fake,nodejs,$(BIN)/node $(BIN)/npm $(BIN)/npx)
update-nodejs:
	$(MAKE) -B $(DL)/fnm-install.sh
	$(MAKE) $(fake-nodejs)

else
$(call fake,nodejs)
endif

clean-nodejs:
	rm -rf "$(DEVENV)/fnm/" \
		"$(BIN)/node" "$(BIN)/npm" "$(BIN)/npx" \
		"$(fake-nodejs)" "$(fake-install-nodejs)"

.PHONY: npm clean-npm update-npm update-npm-impl
$(call fake,npm,$(fake-nodejs))

NPM = $(DEVENV)/npm

NPM_PACKAGES =
NPM_BIN =
npm: | $(NPM)/.exists
	npm install --prefix "$(NPM)" $(NPM_PACKAGES)
	npm audit --prefix "$(NPM)"

update-npm-impl: update-nodejs
	npm update --prefix "$(NPM)"
	npm audit --prefix "$(NPM)"
	touch "$(fake-npm)"

clean-npm:
	rm -rf "$(NPM)" \
		$(NPM_BIN) \
		"$(fake-npm)"

define npm-impl=
NPM_PACKAGES += $2
NPM_BIN += $$(BIN)/$1
$$(NPM)/node_modules/.bin/$1: $$(fake-npm)
$$(call linkbin,$$(NPM)/node_modules/.bin/$1)
update-npm: update-npm-impl
endef

npm = $(eval $(call npm-impl,$1,$(if $2,$2,$1)))
