.PHONY: plugin plugin-clean plugin-update

plugin: $(CACHE)/.exists $(STATE)/.exists

define plugin-git-impl =

HEAD := $$(PLUGIN)/$(notdir $1)/.git/HEAD

$$(HEAD): $$(PLUGIN)/.exists
	git clone --depth 1 --single-branch \
		$(if $2,--branch "$2",) \
		"$1" "$$(PLUGIN)/$(notdir $1)"
	touch "$$(fake-plugin-preclean-$(notdir $1))"

$$(call fake,plugin-preclean-$(notdir $1),$$(HEAD))
plugin-preclean-$(notdir $1):
	cd "$$(PLUGIN)/$(notdir $1)" && git clean -fdx

$$(call fake,plugin-$(notdir $1),$$(fake-plugin-preclean-$(notdir $1)))

.PHONY: plugin-clean-$(notdir $1)
plugin-clean-$(notdir $1):
	rm -rf "$$(PLUGIN)/$(notdir $1)" \
		"$$(fake-plugin-$(notdir $1))" \
		"$$(fake-plugin-preclean-$(notdir $1))"

.PHONY: plugin-update-$(notdir $1)
plugin-update-$(notdir $1):
	cd "$$(PLUGIN)/$(notdir $1)" && git reset --hard HEAD
	cd "$$(PLUGIN)/$(notdir $1)" && git pull --depth=1
	$$(MAKE) $$(fake-plugin-$(notdir $1))

plugin: $$(fake-plugin-$(notdir $1))
plugin-clean: plugin-clean-$(notdir $1)
plugin-update: plugin-update-$(notdir $1)

undefine HEAD
endef

define plugin-local-impl =
$$(PLUGIN)/$1: $$(PLUGIN)/.exists
	ln -snf "$$(abspath plugin.d/$1)" "$$@"

$$(call fake,plugin-$1)
plugin-$1: | $$(PLUGIN)/$1

.PHONY: plugin-clean-$1
plugin-clean-$1:
	rm -f "$$(PLUGIN)/$1" \
		"$$(fake-plugin-$1)"

plugin: $$(fake-plugin-$1)
plugin-clean: plugin-clean-$1
endef

plugin-git = $(eval $(call plugin-git-impl,$1,$2))
plugin-github = $(call plugin-git,https://github.com/$1,$2)
plugin-local = $(eval $(call plugin-local-impl,$1))
