RUSTUP_HOME = $(CFG_PATH_DL)/rustup
CARGO_HOME  = $(CFG_PATH_DL)/cargo

ifeq ($(OS),Windows_NT)
RUSTUP_INIT=$(CFG_PATH_DL)/rustup-init.exe

$(RUSTUP_INIT): | $(CFG_PATH_DL)/.exists
	$(call wget,https://win.rustup.rs,$@)
else
RUSTUP_INIT=$(CFG_PATH_DL)/rustup-init.sh

$(RUSTUP_INIT): | $(CFG_PATH_DL)/.exists
	$(call wget,https://sh.rustup.rs,$@)
	chmod +x "$@"
endif

define rustup-export-impl =
$1: export RUSTUP_HOME := $$(abspath $$(RUSTUP_HOME))
$1: export CARGO_HOME := $$(abspath $$(CARGO_HOME))
$1: export RUSTUP_INIT_SKIP_PATH_CHECK = yes
$1: export PATH := $$(abspath $$(CARGO_HOME))/bin:$$(PATH)
$1: export CARGO_TERM_PROGRESS_WHEN := never
endef
rustup-export = $(eval $(call rustup-export-impl,$1))

rustup = MAKEFLAGS= $(call lock,rustup -q $1,rust)
cargo = MAKEFLAGS= $(call lock,cargo $1,rust)

$(call rustup-export,$(CARGO_HOME)/bin/rustup)
$(CARGO_HOME)/bin/rustup: $(RUSTUP_INIT) | $(CARGO_HOME)/.exists $(RUSTUP_HOME)/.exists
	MAKEFLAGS= "$(RUSTUP_INIT)" -y --no-modify-path --default-toolchain none

$(call fake,rustup-%,$(CARGO_HOME)/bin/rustup)
$(call rustup-export,rustup-%)
rustup-%: $(CARGO_HOME)/bin/rustup
	$(call rustup,toolchain install $*)

.PHONY: update-rustup
$(call rustup-export,update-rustup)
update-rustup: $(CARGO_HOME)/bin/rustup
	$(call rustup,update)

define rustup-toolchain-impl =
$(call rustup-export-impl,$1)
$1: $$(call fake-target,rustup-$2)
ifneq ($$(fake-$1),)
$$(fake-$1): $$(call fake-target,rustup-$2)
endif
endef
rustup-toolchain = $(eval $(call rustup-toolchain-impl,$1,$2))

ifeq ($(OS),Windows_NT)
CARGO_TOOLCHAIN = stable-x86_64-pc-windows-gnu
else
CARGO_TOOLCHAIN = stable
endif

$(call fake,cargo)
$(call rustup-toolchain,cargo,$(CARGO_TOOLCHAIN))
cargo:
	$(call cargo,+$(CARGO_TOOLCHAIN) install cargo-update)

$(call rustup-toolchain,update-cargo,$(CARGO_TOOLCHAIN))
.PHONY: update-cargo
update-cargo: update-rustup $(fake-cargo)
	$(call cargo,+$(CARGO_TOOLCHAIN) install-update -a)

define cargo-install-impl-bin =

$$(CARGO_HOME)/bin/$2: $$(fake-cargo-$1)
$$(BIN)/$2: $$(CARGO_HOME)/bin/$2 | $$(BIN)/.exists
	install "$$<" "$$@"

update-bin-$2: update-cargo
	$$(MAKE) $$(BIN)/$2

endef

define cargo-install-impl =
$$(call fake,cargo-$1)
$$(call rustup-toolchain,cargo-$1,$$(CARGO_TOOLCHAIN))
cargo-$1:
	$$(call cargo,+$$(CARGO_TOOLCHAIN) install $1)

$(foreach b,$2,$(call cargo-install-impl-bin,$1,$b))
endef
cargo-install = $(eval $(call cargo-install-impl,$1,$(if $2,$2,$1)))

.PHONY: clean-rust
clean-rust:
	rm -rf "$(RUSTUP_INIT)" "$(RUSTUP_HOME)" "$(CARGO_HOME)" \
		"$(fake-cargo)" \
		$(call fake-target,rustup-*) \
		$(call fake-target,cargo-*)
