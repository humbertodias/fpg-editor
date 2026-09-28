# Variables
LPI = pfpgeditor.lpi
APP = fpg-editor
LANG_DIR = languages
ARCH = x86_64
WIDGET = qt6
# Extra lazbuild flags (e.g. --lazarusdir=... or --opt=-Fl/path)
LAZ_OPTS ?=
# Optional full path to pas2js. Otherwise PATH, then .tools/, then a download.
PAS2JS ?=
PAS2JS_ZIP_URL ?= https://getpas2js.freepascal.org/downloads/linux/pas2js-linux-x86_64-current.zip

# lazbuild --cpu uses FPC names (aarch64); package archives may use arm64.
CPU := $(ARCH)
ifeq ($(ARCH),arm64)
CPU := aarch64
endif

# Build commands
BUILD_CMD = lazbuild --cpu=$(CPU) --widgetset=$(WIDGET) --build-mode=DefaultQT --verbose $(LAZ_OPTS) $(LPI)
BUNDLE = bash scripts/bundle-qt.sh

.PHONY: all clean build run package build/lin build/mac build/win \
	run/lin run/mac run/win package/lin package/mac package/win install/deps web

# Build targets (Qt6 on all platforms)
build/lin:
	$(BUILD_CMD)

build/mac:
	$(BUILD_CMD)

build/win:
	$(BUILD_CMD)

# Run targets (dev: needs system Qt6Pas)
run/lin:
	@if [ ! -f $(APP) ]; then $(MAKE) build/lin; fi
	./$(APP)

run/mac:
	@if [ ! -f $(APP) ]; then $(MAKE) build/mac; fi
	./$(APP)

run/win:
	@if [ ! -f $(APP).exe ]; then $(MAKE) build/win; fi
	./$(APP).exe

# Package targets — self-contained tree with Qt6Pas + Qt6 libs
package/lin: build/lin
	$(BUNDLE) linux

package/mac: build/mac
	$(BUNDLE) mac

package/win: build/win
	$(BUNDLE) win

# Browser viewer. pas2js compiles the editor units via web/fpgweb.lpi.
# lazbuild resolves CompilerPath "pas2js" relative to web/ unless --compiler is set.
web:
	@set -eu; \
	PAS2JS_BIN="$(PAS2JS)"; \
	if [ -z "$$PAS2JS_BIN" ]; then PAS2JS_BIN=$$(command -v pas2js || true); fi; \
	if [ -z "$$PAS2JS_BIN" ] && [ -d "$(CURDIR)/.tools/pas2js" ]; then \
	  PAS2JS_BIN=$$(find "$(CURDIR)/.tools/pas2js" -type f -name pas2js | head -n1); \
	fi; \
	if [ -z "$$PAS2JS_BIN" ] || [ ! -x "$$PAS2JS_BIN" ]; then \
	  mkdir -p "$(CURDIR)/.tools/pas2js"; \
	  curl -fL -o "$(CURDIR)/.tools/pas2js.zip" "$(PAS2JS_ZIP_URL)"; \
	  unzip -qo "$(CURDIR)/.tools/pas2js.zip" -d "$(CURDIR)/.tools/pas2js"; \
	  PAS2JS_BIN=$$(find "$(CURDIR)/.tools/pas2js" -type f -name pas2js | head -n1); \
	  test -n "$$PAS2JS_BIN"; \
	  chmod +x "$$PAS2JS_BIN"; \
	fi; \
	echo "Using pas2js: $$PAS2JS_BIN"; \
	lazbuild --compiler="$$PAS2JS_BIN" --build-mode=Default $(LAZ_OPTS) web/fpgcheck.lpi; \
	lazbuild --compiler="$$PAS2JS_BIN" --build-mode=Default $(LAZ_OPTS) web/fpgweb.lpi; \
	node web/fpgcheck.js

install/deps:
	sudo apt update
	sudo apt install -y fpc fp-compiler-3.2.2 libqt6pas-dev libqt6pas6 qt6-base-dev

# Clean
clean:
	rm -f *.res $(APP) $(APP).exe
	rm -rf dist $(APP)-*-*.tar.gz $(APP)-*-*.zip
