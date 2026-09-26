.PHONY: clean-nodejs
ifeq ($(CFG_NODEJS_NATIVE),)
$(call dl,https://fnm.vercel.app/install,fnm-install.sh)
$(CFG_PATH_DEVENV)/fnm/fnm: $(CFG_PATH_DL)/fnm-install.sh | $(CFG_PATH_DEVENV)/fnm/.exists
	$(call lock,$(SHELL) "$<" -s -d "$(dir $@)",nodejs)
	touch -r "$<" "$@"

.PHONY: update-fnm
update-fnm: update-dl-fnm-install.sh
	$(MAKE) $(CFG_PATH_DEVENV)/fnm/fnm

ifeq ($(OS),Windows_NT)
NODEJS_BINDIR = $(CFG_PATH_DEVENV)/fnm/aliases/lts-latest
else
NODEJS_BINDIR = $(CFG_PATH_DEVENV)/fnm/aliases/lts-latest/bin
endif

.PHONY: update-nodejs
$(call fake,install-nodejs,$(CFG_PATH_DEVENV)/fnm/fnm)
update-nodejs: update-fnm
install-nodejs update-nodejs:
	$(call lock,"$(CFG_PATH_DEVENV)/fnm/fnm" --log-level error --fnm-dir="$(abspath $(CFG_PATH_DEVENV)/fnm)" install --lts,nodejs)

$(call side-effects,$(fake-install-nodejs),$(NODEJS_BINDIR)/node $(NODEJS_BINDIR)/npm $(NODEJS_BINDIR)/npx)

$(call linkbin,$(NODEJS_BINDIR)/node)
$(call linkbin,$(NODEJS_BINDIR)/npm)
$(call linkbin,$(NODEJS_BINDIR)/npx)

update-bin-node update-bin-npm update-bin-npx: update-nodejs

$(call fake,nodejs,$(BIN)/node $(BIN)/npm $(BIN)/npx)

clean-nodejs: clean-bin-node clean-bin-npm clean-bin-npx
	rm -rf "$(CFG_PATH_DEVENV)/fnm" \
		"$(fake-install-nodejs)" \
		"$(fake-nodejs)"
else
$(call fake,nodejs)
clean-nodejs:
	rm -f "$(fake-nodejs)"
endif

NPM_DIR = $(CFG_PATH_DEVENV)/npm

.PHONY: clean-npm
clean-npm:
	rm -rf "$(NPM_DIR)" \
		$(call fake-target,npm-*)

.PHONY: update-npm
update-npm: export CI := true
update-npm: $(if $(CFG_NODEJS_NATIVE),,update-bin-node update-bin-npm update-bin-npx)
	$(call lock,npm update --prefix "$(NPM_DIR)",nodejs)
	$(call lock,npm audit --prefix "$(NPM_DIR)",nodejs)


define npm-impl-bin =

$$(NPM_DIR)/node_modules/.bin/$2: $$(fake-npm-$1)
$$(call linkbin,$$(NPM_DIR)/node_modules/.bin/$2)
update-bin-$2: update-npm
clean-npm: clean-bin-$2
endef

define npm-impl =
$$(call fake,npm-$1,$$(fake-nodejs))
npm-$1: export CI := true
npm-$1: | $(NPM_DIR)/.exists
	$$(call lock,npm install --prefix "$$(NPM_DIR)" $1,nodejs)
	$$(call lock,npm audit --prefix "$$(NPM_DIR)",nodejs)

$(foreach b,$2,$(call npm-impl-bin,$1,$b))
endef

npm = $(eval $(call npm-impl,$1,$(if $2,$2,$1)))
