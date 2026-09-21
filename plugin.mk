.PHONY: plugin clean-plugin update-plugin

plugin: | $(CACHE)/.exists $(STATE)/.exists

define plugin-git-impl =

HEAD := $$(PLUGIN)/$(notdir $1)/.git/HEAD

$$(HEAD): | $$(PLUGIN)/.exists
	git clone --depth 1 --single-branch \
		$(if $2,--branch "$2",) \
		"$1" "$$(PLUGIN)/$(notdir $1)"

$$(call fake,clean-plugin-dir-$(notdir $1),$$(HEAD))
clean-plugin-dir-$(notdir $1):
	git -C "$$(PLUGIN)/$(notdir $1)" clean -fdx

$$(call fake,plugin-$(notdir $1),$$(fake-clean-plugin-dir-$(notdir $1)))

.PHONY: clean-plugin-$(notdir $1)
clean-plugin-$(notdir $1):
	rm -rf "$$(PLUGIN)/$(notdir $1)" \
		"$$(fake-plugin-$(notdir $1))" \
		"$$(fake-update-plugin-preclean-$(notdir $1))"

.PHONY: update-plugin-$(notdir $1)
update-plugin-$(notdir $1):
ifneq ($(strip $2),)
	git -C "$$(PLUGIN)/$(notdir $1)" fetch --depth=1 --prune origin \
		"+refs/heads/$2:refs/remotes/origin/$2"
	git -C "$$(PLUGIN)/$(notdir $1)" reset --hard "origin/$2";
else
	git -C "$$(PLUGIN)/$(notdir $1)" fetch --depth=1 --prune origin
	git -C "$$(PLUGIN)/$(notdir $1)" remote set-head origin -a
	git -C "$$(PLUGIN)/$(notdir $1)" reset --hard origin/HEAD
endif
	$$(MAKE) $$(fake-plugin-$(notdir $1))

plugin: $$(fake-plugin-$(notdir $1))
clean-plugin: clean-plugin-$(notdir $1)
update-plugin: update-plugin-$(notdir $1)

undefine HEAD
endef

define plugin-local-impl =
$$(PLUGIN)/$1: | $$(PLUGIN)/.exists
	ln -snf "$$(abspath plugin.d/$1)" "$$@"

$$(call fake,plugin-$1)
plugin-$1: | $$(PLUGIN)/$1

.PHONY: clean-plugin-$1
clean-plugin-$1:
	rm -f "$$(PLUGIN)/$1" \
		"$$(fake-plugin-$1)"

plugin: $$(fake-plugin-$1)
clean-plugin: clean-plugin-$1
endef

plugin-git = $(eval $(call plugin-git-impl,$1,$2))
plugin-github = $(call plugin-git,https://github.com/$1,$2)
plugin-local = $(eval $(call plugin-local-impl,$1))
