.PHONY: plugin clean-plugin update-plugin

plugin: | $(CFG_PATH_CACHE)/.exists $(CFG_PATH_STATE)/.exists

define plugin-git-impl =
PLUGIN_STATE := $$(CFG_PATH_PLUGIN)/$(notdir $1)/.plugin-updated

$$(CFG_PATH_PLUGIN)/$(notdir $1)/.plugin-updated: | $$(CFG_PATH_PLUGIN)/.exists
	git clone --depth 1 --single-branch \
		$(if $2,--branch "$2",) \
		"$1" "$$(CFG_PATH_PLUGIN)/$(notdir $1)"
	touch "$$@"

$$(call fake,plugin-$(notdir $1),$$(CFG_PATH_PLUGIN)/$(notdir $1)/.plugin-updated)

.PHONY: clean-plugin-$(notdir $1)
clean-plugin-$(notdir $1):
	rm -rf "$$(CFG_PATH_PLUGIN)/$(notdir $1)" \
		"$$(fake-plugin-$(notdir $1))"

.PHONY: update-plugin-$(notdir $1)
update-plugin-$(notdir $1): | $$(CFG_PATH_PLUGIN)/$(notdir $1)/.plugin-updated
	$$(TOOLS)/update-plugin.sh \
		"$$(CFG_PATH_PLUGIN)/$(notdir $1)" \
		"$$(CFG_PATH_PLUGIN)/$(notdir $1)/.plugin-updated" \
		"$2"
	$$(MAKE) $$(fake-plugin-$(notdir $1))

plugin: $$(fake-plugin-$(notdir $1))
clean-plugin: clean-plugin-$(notdir $1)
update-plugin: update-plugin-$(notdir $1)
endef

define plugin-local-impl =
$$(CFG_PATH_PLUGIN)/$1: | $$(CFG_PATH_PLUGIN)/.exists
	ln -snf "$$(abspath plugin.d/$1)" "$$@"

$$(call fake,plugin-$1)
plugin-$1: | $$(CFG_PATH_PLUGIN)/$1

.PHONY: clean-plugin-$1
clean-plugin-$1:
	rm -f "$$(CFG_PATH_PLUGIN)/$1" \
		"$$(fake-plugin-$1)"

plugin: $$(fake-plugin-$1)
clean-plugin: clean-plugin-$1
endef

plugin-git = $(eval $(call plugin-git-impl,$1,$2))
plugin-github = $(call plugin-git,https://github.com/$1,$2)
plugin-local = $(eval $(call plugin-local-impl,$1))
