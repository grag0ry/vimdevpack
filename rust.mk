RUSTUP_HOME = $(DEVENV)/rustup
CARGO_HOME  = $(DEVENV)/cargo
RUSTUP_TOOLCHAINS =

ifeq ($(OS),Windows_NT)
RUSTUP_INIT=$(RUSTUP_HOME)/rustup-init.exe

$(RUSTUP_INIT): $(RUSTUP_HOME)/.exists
	$(call wget,https://win.rustup.rs,$@)
else
RUSTUP_INIT=$(RUSTUP_HOME)/rustup-init.sh

$(RUSTUP_INIT): $(RUSTUP_HOME)/.exists
	$(call wget,https://sh.rustup.rs,$@)
	chmod +x "$@"
endif

$(CARGO_HOME)/bin/rustup: $(RUSTUP_INIT)
	"$<" -y --no-modify-path --default-toolchain none

define rustup-export-impl=
$1: export RUSTUP_HOME := $$(abspath $$(RUSTUP_HOME))
$1: export CARGO_HOME := $$(abspath $$(CARGO_HOME))
$1: export RUSTUP_INIT_SKIP_PATH_CHECK = yes
$1: export PATH := $$(abspath $$(CARGO_HOME))/bin:$$(PATH)

endef
rustup-export = $(eval $(call rustup-export-impl,$1))

rustup-toolchains-append = $(if $(filter $1,$(RUSTUP_TOOLCHAINS)),,$(eval $(RUSTUP_TOOLCHAINS) += $1))

$(call fake,rustup)
$(call rustup-export,rustup)
rustup: $(CARGO_HOME)/bin/rustup
	$(foreach tc,$(RUSTUP_TOOLCHAINS), \
		$(CARGO_HOME)/bin/rustup toolchain install $(tc)$(NL) \
	)

define rustup-toolchain-impl=
ifeq ($$(filter $2,$$(RUSTUP_TOOLCHAINS)),)
RUSTUP_TOOLCHAINS += $2
endif
$$(call rustup-export,$1)
$1: $$(fake-rustup)

endef
rustup-toolchain = $(eval $(call rustup-toolchain-impl,$1,$2))

define cargo-install-impl=
$$(call rustup-toolchain,$$(CARGO_HOME)/bin/$1,stable)
$$(CARGO_HOME)/bin/$1:
	cargo install "$2"

$$(call linkbin,$$(CARGO_HOME)/bin/$1)
endef
cargo-install = $(eval $(call cargo-install-impl,$1,$(if $2,$2,$1)))
