# Variables
LPI = pfpgeditor.lpi
APP = fpg-editor
LANG_DIR = languages
ARCH = x86_64
WIDGET = qt6
# Extra lazbuild flags (e.g. macOS: LAZ_OPTS=--add-options=-Fl/Library/Frameworks)
LAZ_OPTS ?=

# Build commands
BUILD_CMD = lazbuild --cpu=$(ARCH) --widgetset=$(WIDGET) --build-mode=DefaultQT --verbose $(LAZ_OPTS) $(LPI)
BUNDLE = bash scripts/bundle-qt.sh

.PHONY: all clean build run package build/lin build/mac build/win \
	run/lin run/mac run/win package/lin package/mac package/win install/deps

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

install/deps:
	sudo apt update
	sudo apt install -y fpc fp-compiler-3.2.2 libqt6pas-dev libqt6pas6 qt6-base-dev

# Clean
clean:
	rm -f *.res $(APP) $(APP).exe
	rm -rf dist $(APP)-*-*.tar.gz
